function dm
    set lastws (getCurrentWorkspace)
    focus-primary
    dmenu_run -p "Command: " -nb "black" -sf "#036300" -sb "#A6CD01" -nf "grey" -fn Inconsolata-12 -b
    ws $lastws
end

function wp
    feh --bg-scale $argv
    convert $argv -resize 1920x1080\! ~/.bgimage/img.png
end

function lock
    # i3lock -i ~/.bgimage/img.png -t
    xscreensaver-command -lock
end

function focus
    i3-msg [class=(capitalize $argv)] focus
end

function new-session
    kdmctl reserve
end

function setme
    set -U $argv[1] $argv[2]
end


function clemctl
    qdbus org.mpris.clementine /Player org.freedesktop.MediaPlayer.{$argv}
end

function get-connected-displays
    xrandr | grep " connected" | cut -d "c" -f1
end

function get-number-of-displays
    count (get-connected-displays)
end

function unset-fullscreen
    if is-fullscreen
        i3-msg fullscreen > /dev/null
    end
end

function is-fullscreen
    xwininfo -id (mywin) -all | grep -i fullscreen > /dev/null
end

function get-primary-display
    xrandr | grep primary | cut -d " " -f1
end

function get-secondary-display
    xrandr | grep " connected [0-9]" | cut -d " " -f1
end

function get-dividing-line
    xrandr | grep "+[1-9]" | cut -d "+" -f2
end

function get-focused-display
    set xcorner (xwininfo -id (mywin) -all | grep -i "corners" | cut -d '+' -f2 | trim) 
    if test $xcorner -gt (get-dividing-line)
        get-secondary-display
    else
        get-primary-display
    end
end

function get-focused-display-resolution
    set res (xrandr --verbose | grep " connected" | grep (get-focused-display) | cut -d "x" -f1-2 | cut -d "+" -f1)
    set res (explode $res)
    set res $res[-1]
    echo $res
end

function get-focused-display-width
    get-focused-display-resolution | cut -d "x" -f1
end

function get-focused-display-height
    get-focused-display-resolution | cut -d "x" -f2
end

function get-window-width
    xwininfo -id (mywin) | grep "Width" | cut -d ":" -f2  | trim
end

function get-window-height
    xwininfo -id (mywin) | grep "Height" | cut -d ":" -f2  | trim
end

function set-window-size
    set numargs (count $argv)
    switch $numargs
        case "3"
            set method $argv[1]
            set dimension $argv[2]
            set num $argv[3]
        case "2"
            set method $argv[1]
            set dimension $resizedim
            set num $argv[2]
    end

    switch $method
        case "exact"
            set targetsize $num
        case "aprox"
            set targetsize (math "$num * 100")
        case "perc"
            switch $dimension
                case "width"
                    set rescommand get-focused-display-width
                case "height"
                    set rescommand get-focused-display-height
            end
            set maxsize (eval $rescommand)
            set multiplier "0.$num"
            set targetsize (math "$maxsize * $multiplier")
    end 
    set sizecommand get-window-{$dimension}
    set currentsize (eval $sizecommand)
    set difference (math "($currentsize - $targetsize) / 16")
    if greaterthanzero $difference
        set direction shrink
    else
        set direction grow
        set difference (abs $difference)
    end
    set command i3-msg resize $direction $dimension $difference px or $difference ppt
    eval $command
end

function trans
    transset -i (currentapp) $argv
end

function abs
    if greaterthanzero $argv
        echo $argv
    else
        math "$argv - ($argv * 2)"
    end
end

function greaterthanzero
    if test $argv -gt 0
        return 0
    else
        return 1
    end
end

function another-trans
    transset -i (xdotool getactivewindow) .{$argv}
end

function currentapp
    echo (xdotool getactivewindow)
end

function transparent
    transset -i (currentapp) .86
end

function solid
    transset -i (currentapp) 1.0
end

function nextwindow
    set currentclass (xprop -id (currentapp) | grep WM_CLASS | cut -d '"' -f4)
    nextmatch $currentclass
end

function pi3
   echo "import i3"\n{$argv} | python
end 

function getCurrentWorkspace
    pi3 "print i3.filter(i3.get_workspaces(), focused=True)[0]['name']"
end

function capitalize
    echo $argv | sed 's/\([a-z]\)\([a-z]*\)/\U\1\L\2/g'
end

function explode
    echo $argv | sed 's/ /\n/g'
end

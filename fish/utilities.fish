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
    xrandr --verbose | grep primary | cut -d " " -f1
end

function get-secondary-display
    xrandr --verbose | grep " connected 1" | cut -d " " -f1
end


function trans
    transset -i (currentapp) $argv
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

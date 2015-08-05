function dm
    switch $argv[1]
        case "run"
            dmenu_run -nb "black" -sf "#036300" -sb "#A6CD01" -nf "grey" -fn Inconsolata-13 -b -l 10 -i -p "Command: "
        case "menu"
                dmenu -nb "black" -sf "#036300" -sb "#A6CD01" -nf "grey" -fn Inconsolata-13 -b -l 10 -i -p $argv[2]
        case "choice"
            echo "" | dm menu "$argv[2]"
    end
end



function wp0 -d 'usage: [max,scale,tile] path-to-image or path-to-image or [max,scale,tile]'
    set dest ~/.bgimage/img.png
    switch (count $argv)
        case "2"
            set style $argv[1]
            if test -f $argv[2]
                set image (pathof $argv[2])
            else
                set image /mnt/ext/Images/backgrounds/$argv[2]
            end
        case "1"
            set image ~/.bgimage/img.png
            switch $argv[1]
                case "max"
                    set style max
                case "scale"
                    set style scale
                case "center"
                    set style center
                case "fill"
                    set style fill
                case "tile"
                    set style tile
                case "*"
                    set style max
                    set image (pathof $argv[1])
           end
    end
    feh --bg-$style $image
    if not match $image $bgpath
        echo converting...
        convert $image -resize 1920x1080\! $dest &
    end
    set -U bgpath $image
end

function wp2
    set dest ~/.bgimage/img.png
    set resolution 1920x1080

    if matches $argv "max|scale|tile"
        echo first
        set style $argv
        set image $dest
    else if matches "$argv" "max|tile|scale \S*"
        echo second
        set style $argv[1]
        set image (pathof $argv[2])
    else if matches $argv "\S*"
        echo third
        set style scale
        set image (pathof $argv[1])
    end

    echo i is $image s is $style
    feh --bg-$style $image
    echo converting...
    convert $image -resize 1920x1080\! $dest
end

function lock
    # i3lock -i ~/.bgimage/img.png -t
    xscreensaver-command -lock
    xset dpms force off
end

function focus
    set original (wininfo id dec)
    switch $argv[1]
        case "id"
            set criteria id
            set choice (ensure-dec $argv[2])
        case "class"
            set criteria class
            set choice \'(return-windowclass $argv[2])\'
        case "output"
            im focus output $argv[2]
            return 0
        case "urgent"
            im [urgent=latest] focus
        case "ws"
            im focus $argv[2]
            return 0
        case "regex"
            set criteria $argv[2]
            set choice \'$argv[3]\'
        case "*"
            if test (count $argv) -eq 1
                set criteria class
                set choice \'(return-windowclass $argv[1])\'
            else
                set criteria $argv[1]
                set choice \'$argv[2]\'
            end
    end
    im [$criteria=$choice] focus
    set final (wininfo id dec)
    if [ $final = $original ]
        return 1
    end
end

function return-windowclass
    # set xs (explode $argv[1])
    if test (count $argv -eq 1)
        set xs (explode $argv)
    else
        set xs $argv
    end
    switch $xs[1]
        case calibre
            set returnval libprs500
        case urxvt
            set returnval URxvt
        case urxvtc
            set returnval URxvt
        case urxvtt
            set returnval URxvt
        case clem
            set returnval Clementine
        case mpv
            set returnval mpv
        case kdesudo
            set returnval (return-windowclass $argv[2..-1])
        case lilyterm
            set returnval LilyTerm
        case nv
            set returnval LilyTerm
        case sudo
            # set returnval (return-windowclass $argv[2..-1])
            set returnval (return-windowclass $xs[2..-1])
        case books
            set returnval Zathura
        case mm
            switch $xs[2]
                case read
                    set returnval Zathura
                    set returnval 'Zathura|libprs500'
                case watch
                    set returnval mpv
            end
        case ffs
            set returnval Firefox
        case "*"
            set returnval (capitalize $argv)
    end
    echo $returnval
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

function unset-fullscreen
    if is-fullscreen
        i3-msg fullscreen > /dev/null
    end
end

function is-fullscreen
    xwininfo -id (wininfo id dec) -all | grep Fullscreen > /dev/null
end

function get-primary-display
    xrandr | grep primary | cut -d " " -f1
end

function get-secondary-display
    xrandr | grep " connected [0-9]" | cut -d " " -f1
end

function get-focused-display
    get-ws-info get output where focused = true
end

function get-focused-display-resolution
    set res (xrandr --verbose | grep " connected" | grep (get-focused-display) | cut -d "x" -f1-2 | cut -d "+" -f1)
    set res (explode $res)
    set res $res[-1]
    echo $res
end

function get-focused-display-offset
    xrandr --verbose | grep " connected" | grep (get-focused-display) | cut -d "x" -f1-2 | cut -d "+" -f2
end

function get-focused-display-x-offset
    get-ws-info get x where output = (quote (get-focused-display)) | sort -u
end

function get-focused-display-y-offset
    get-ws-info get y where output = (quote (get-focused-display)) | sort -u
end

function screenshot
    set target ~/screenshots/(mydate).png
    switch $argv
        case "everything"
            maim $target
        case "window"
            maim -x (get-window-x-pos) -y (get-window-y-pos) -w (get-window-width) -h (get-window-height) $target
        case "display"
            maim -x (get-focused-display-x-offset) -y (get-focused-display-y-offset) -w (get-focused-display-width) -h (get-focused-display-height) $target
   end
   echo $target
end


function get-focused-display-width
    get-focused-display-resolution | cut -d "x" -f1
end

function get-focused-display-height
    get-focused-display-resolution | cut -d "x" -f2
end

function get-window-width
    xwininfo -id (wininfo id dec) | grep "Width" | cut -d ":" -f2  | trim
end

function get-window-height
    xwininfo -id (wininfo id dec) | grep "Height" | cut -d ":" -f2  | trim
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

function resize-window
    set dim $argv[1]
    set num (abs $argv[2])
    if test $argv[2] -gt 0
        set direction grow
    else
        set direction shrink
    end
    im resize $direction $dim {$num}px or {$num}pc
end

function adjust-height
    resize-window height $argv
end

function adjust-width
   resize-window width $argv
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

function capitalize
    echo $argv | sed 's/\([a-z]\)\([a-z]*\)/\U\1\L\2/g'
end

function explode
    if substr $argv @
        set char @
    else
        set char ' '
    end

    echo $argv | sed "s/$char/\n/g"
end

function xdc
    xdotool getactivewindow $argv
end

function windowmove
    set directions left right down up
    if contains $argv[1] $directions
        windowmove-relative $argv
    else
        xdc windowmove $argv
    end
end

function get-window-x-pos
    xwininfo -id (wininfo id dec) | grep "Absolute upper-left X" | cut -d ":" -f2 | trim
end

function get-window-y-pos
    xwininfo -id (wininfo id dec) | grep "Absolute upper-left Y" | cut -d ":" -f2 | trim
end

function windowmove-relative
    set xpos (get-window-x-pos)
    set ypos (get-window-y-pos)
    set direction $argv[1]
    set distance $argv[2]
    switch $direction
        case "left"
            set xpos (math "$xpos - $distance")
        case "right"
            set xpos (math "$xpos + $distance")
        case "up"
            set ypos (math "$ypos - $distance")
        case "down"
            set ypos (math "$ypos + $distance")
    end
    if test $xpos -lt 0
        set xpos 0
    end
    if test $ypos -lt 0
        set ypos 0
    end
    xdc windowmove $xpos $ypos
end


function center-window
    set width (get-focused-display-width)
    set height (get-focused-display-height)
    set winwidth (get-window-width)
    set winheight (get-window-height)
    set xcord (math (math "$width / 2") - (math "$winwidth / 2"))
    set ycord (math (math "$height / 2") - (math "$winheight / 2"))
    xdotool getactivewindow windowmove $xcord $ycord
end

function alphabet
    set lst a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
    println $lst
end

function command-for-window
end

function dectohex
    printf 0x0'%x\n' $argv
end

function hextodec
    printf '%d\n' $argv
end

function format-for-matchlist
    set size (count $argv)
    set n 0
    for i in $argv
        set n (increase $n)
        if test $n -ne $size
            set acc $acc (echo {$i}@)
        else
            set acc $acc $i
        end
    end
    # set size (math (sizeof $acc) - 1
    echo $acc
end

function get-display-left-to-right
    set outputs (xrandr | grep " connected" | cut -d " " -f1)
    set offsets (xrandr | grep " connected" | cut -d + -f2)
    set sorted (println $offsets | sort)
    for i in (seq (count $outputs))
        set x (findindex $sorted[$i] $offsets)
        set lst $lst $outputs[$x]
    end
    println $lst
end

function get-number-of-displays
    count (get-connected-displays)
end

function get-display-order
    set outputs (xrandr | grep " connected" | cut -d " " -f1)
    set ordered (get-display-left-to-right)
    for i in $outputs
        math (findindex $i $ordered) - 1
    end
end

function get-connected-displays
    get-ws-info get output where visible = true
end

function wininfo
    switch $argv[1]
        case title
            xprop -id (xdotool getactivewindow) _NET_WM_NAME | cut -d "=" -f2 | trim
        case id
                switch $argv[2]
                    case dec
                        xdotool getactivewindow
                    case hex
                        ensure-hex (xdotool getactivewindow)
                end
        case class
            xprop -id (xdotool getactivewindow) WM_CLASS | cut -d "," -f2 | trim
        case pid
            xprop -id (xdotool getactivewindow) _NET_WM_PID | cut -d "=" -f2 | trim
    end
end

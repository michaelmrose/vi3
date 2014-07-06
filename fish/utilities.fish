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
    #i3lock -i /tmp/util_bg.png -t
    xscreensaver-command -lock
end

function focus
    set winclass (capitalize $argv)   
    i3-msg [class=$winclass] focus
end

function new-session
    kdmctl reserve
end

function setme
    set -U $argv[1] $argv[2]
end

function setvol
    pactl -- set-sink-volume $default_sink {$argv}%
    set vol (getvol)
    killall notify-osd
    notify-send --expire-time=1 "volume set to $vol"
end

function clemctl
    qdbus org.mpris.clementine /Player org.freedesktop.MediaPlayer.{$argv}
end

function capitalize
    echo $argv | sed 's/\([a-z]\)\([a-z]*\)/\U\1\L\2/g'
end

function audio-next
    clemctl Next
end

function audio-prev
    clemctl Prev
end

#does NOT work
function audio-play
    clemctl Pause
    xdotool key XF86AudioPlay
end

function trans
    currentapp
    transset -i $mywin $argv
end

function another-trans
    transset -i (xdotool getactivewindow) .{$argv}
end

function currentapp
    set -U mywin (xdotool getactivewindow)
end

function transparent
    currentapp
    transset -i $mywin .86
end

function solid
    currentapp
    transset -i $mywin 1.0
end

function nextwindow
    currentapp
    set currentclass (xprop -id $mywin | grep WM_CLASS | cut -d '"' -f4)
    nextmatch $currentclass
end

#important pulse sinks are zero indexed but lists in fish are 1 indexed this is
#the source of the error

function move-all-audio-streams
    set apps (pacmd list-sink-inputs | sed -n -e 's/index:[[:space:]]\([[:digit:]]\)/\1/p')
    # set targetop (math $argv-1)
    for i in $apps
        pacmd "move-sink-input $i $argv"
        
    end
end

function get-number-of-sinks
    pacmd list-sinks | grep -c index:[[:space:]][[:digit:]]
end

function get-output-index
    set nsinks (math (get-number-of-sinks)-1)
    set nextsink (math $default_sink+1)
    if math "$nextsink>$nsinks" > /dev/null
        set nextsink 0
    end
    switch $argv
        case headphones
            echo 0
        case speakers
            echo 1
        case next
            echo $nextsink
    end
end

function set-default-sink
    set targetop (math $argv-1)
    pacmd "set-default-sink $targetop"
end

function switch-output
    # set ndx (get-output-index $argv)
    # set-default-sink $ndx
    # move-all-audio-streams $ndx
    # set -U default_sink $ndx
    # set op (current-output)
    # msg --id 7 -t "output changed to $op"
    switchaudio.sh
    signal-i3blocks volume
    signal-i3blocks output
end

function list-outputs
    set outputs (pacmd list-sinks | sed -n -e 's/device.description[[:space:]]=[[:space:]]"\(.*\)"/\1/p')
    set cnt 0
    for i in $outputs
        if [ $cnt = $default_sink ]
            echo \* $i
        else
            echo $i
        end
        # inc cnt
        set cnt (math cnt + 1)
    end
end

function list-displays
   set displays (get-connected-displays)
   set primary (get-primary-display)
   for i in $displays
       if match $i $primary 
           echo \* $i
       else
           echo " " $i
       end
   end
end

function current-output
    set op (list-outputs)
    set ndx (math $default_sink+1)
    echo $op[$ndx] | sed 's/\t//g' | sed 's/*//g' | trim
    return 0
end

function output-type
    switch (current-output)
        case "Clear Chat Comfort USB Headset Analog Stereo"
            echo headphones
        case "Built-in Audio Analog Stereo"
            echo speakers
    end
end

function setvol
    pactl -- set-sink-volume $default_sink {$argv}%
    set vol (getvolume)
    signal-i3blocks volume
end

function getvolume
    set vols (pactl list sinks | grep "Volume: 0: " | cut -c13-16 | trim)
    set ndx (math "$default_sink + 1")
    echo $vols[$ndx]
end

function clear-playlist
    set tmp /tmp/empty
    touch $tmp
    clementine -l $tmp 
    mm stop
end    
    
function lyrics
    beet lyrics $argv -p | cut -d ';' -f12- | cut -d ';' -f1- | less
end
    
function media-ctl
    set nargs (count $argv)
    switch $argv[1] 
        case play 
            if [ $nargs = 1 ]
                playerctl --player=$PLAYER play-pause
            else
                #add results matching query to current playlist
                beet play $argv[2..-1]
            end

        case clear
            clear-playlist
        case vol
            setvol $argv[2]
        case playing
            #print title of playing track
            playing
        case lyrics
            #print lyrics of playing tracks
            lyrics (media-ctl playing)
        case outputs
            list-outputs
        case output
            switch-output $argv[2..-1]
        case displays
            list-displays 
        case read
            books $argv[2..-1]
        case watch
            watch-video $movie $argv[2..-1]
        case "*"
            #handles play pause stop next previous
            playerctl --player=$PLAYER $argv
        end
end

function playing
    set title (playerctl metadata title)
    set artist (playerctl metadata artist)
    if exists $title
        echo $title by $artist
    else
        echo None
    end
end

function show-playing
    msg (playing)
end

function get-volumes
    pactl list sinks | sed -n -e '/State: RUNNING/,$p' | grep "Volume: 0" | cut -d ":" -f3 | cut -d "%" -f1 | trim
end

alias mm media-ctl 

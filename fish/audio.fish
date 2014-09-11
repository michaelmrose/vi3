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
    set ndx (get-output-index $argv)
    set-default-sink $ndx
    move-all-audio-streams $ndx
    set -U default_sink $ndx
    set op (current-output)
    msg --id 7 -t "output changed to $op"
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
        set cnt (math "$cnt+1")
    end
end

function current-output
    set op (list-outputs)
    set ndx (math $default_sink+1)
    echo $op[$ndx] | sed 's/\t//g' | sed 's/*//g'
end

function setvol
    pactl -- set-sink-volume $default_sink {$argv}%
    set vol (getvol)
    msg --id 8 -t "volume set to $vol"
end

function clear-playlist
    clementine -l nil
    mm stop
end    
    
function lyrics
    beet lyrics $argv -p | cut -d ';' -f12- | cut -d ';' -f1- | less
end
    
function media-ctl
    switch $argv[1] 
        case add 
            #add results matching query to current playlist
            beet play $argv[2..-1]
        case clear
            clear-playlist
        case vol
            setvol $argv[2]
        case playing
            #print title of playing track
            pacmd list-sink-inputs | grep media.title | cut -d '"' -f2
        case lyrics
            #print lyrics of playing tracks
            lyrics (media-ctl playing)
        case outputs
            list-outputs
        case output
            switch-output $argv[2..-1]
            #switchaudio.sh
        case read
            books $argv[2..-1]
        case "*"
            #handles play pause stop next previous
            playerctl --player=$PLAYER $argv
        end
end

alias mm media-ctl 

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
    # switchaudio.sh
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
    set output (current-output)
    if substr $output Headset
        echo headphones
    else
        echo speakers
    end
end

function output-status-line
    switch (output-type)
        case headphones
            set symbol 
        case speakers
            set symbol 
        case "*"
            set symbol 
    end
    echo $symbol (getvolume)
end

function setvolume
    ponymix (match-lists (car $argv) "+ -" "increase decrease" set-volume) (stripsign $argv)
    signal-i3blocks output
end

function output-list
    pacmd list-sinks | sed -n -e 's/device.description[[:space:]]=[[:space:]]"\(.*\)"/\1/p' | condense_spaces
end

function play-music
    set tracks (beet ls $argv --path)
    clementine -a $tracks
    echo playing (count $tracks) tracks
end

function play-music2
    if [ $argv[1] = -e ]
        set criteria $argv[2]
        set query $argv[3..-1]
    else
        set criteria title
        set query $argv
    end
    set tracks (beet ls $query)

    set artist (println $tracks | cut -d "-" -f1 | trim)
    set album (println $tracks | cut -d "-" -f2 | trim)
    set title (println $tracks | cut -d "-" -f3 | trim)
    set c (println $$criteria)

    #clementine -a $tracks
    for i in (range (count $tracks))
        # echo c is $c[$i] and q is $query
        if substr $c[$i] $query
            set queue $queue (echo $artist[$i] $album[$i] $title[$i])
        end
    end
    println $queue
    for i in $queue
    end
    echo playing (count $tracks) tracks
end

function renderstringplayable
    echo $argv | sed 's/[()-]//g' | condense_spaces
end

function play-list
        set count 0
    for i in $argv
        play-music $i
    end
end

alias setvol setvolume

function getvolume
    set result (ponymix get-volume)%
    if ponymix is-muted
        set result \($result\)
    end
    echo $result
end

function toggle-mute
    ponymix toggle
    signal-i3blocks output
end

alias getvol getvolume

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
    set xs (padded $argv)
    switch $argv[1]
        case play
            if [ $nargs = 1 ]
                playerctl --player=$PLAYER play-pause
            else
                #add results matching query to current playlist
                play-music $argv[2..-1]
            end

        case clear
            clear-playlist
        case vol
            setvol $argv[2]
        case mute
            toggle-mute
        case playing
            #print title of playing track
            playing
        case lyrics
            #print lyrics of playing tracks
            lyrics (media-ctl playing)
        case outputs
            list-outputs
        case output
            switch-output
        case status
            playerctl status
        case displays
            list-displays
        case read
            books $xs[2..-1]
        case watch
            watch-video $argv[2..-1]
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

function player-status-line
    switch (playerctl status)
        case Paused
            set symbol "  "
        case Playing
            set symbol "  "
    end
    echo $symbol (playing)
end

function is-muted
    ponymix is-muted
end

function show-playing
    msg (playing)
end

function volume-status-line
    set vol (getvolume)
    if is-muted
        echo  $vol
    else
        echo  $vol
    end
end

function get-volumes
    pactl list sinks | sed -n -e '/State: RUNNING/,$p' | grep "Volume: 0" | cut -d ":" -f3 | cut -d "%" -f1 | trim
end

alias mm media-ctl

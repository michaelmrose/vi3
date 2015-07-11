#!/usr/bin/fish
function switchaudio2
        set sinks_count (pacmd list-sinks | grep -c index:[[:space:]][[:digit:]])
        set active_sink_index (pacmd list-sinks | sed -n -e 's/\*[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p')
        set major_sink_index (math "$sinks_count -1")
        set next_sink_index 0

        echo sinks_count is $sinks_count
        echo active_sink_index is $active_sink_index
        echo major_sink_index is $major_sink_index
        echo next_sink_index is $next_sink_index 
        if not match $active_sink_index $major_sink_index
            set next_sink_index (math "$active_sink_index + 1")
        end

        pacmd "set-default-sink $next_sink_index"
        for i in 
end

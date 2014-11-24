#!/bin/bash

declare -i sinks_count=`pacmd list-sinks | grep -c index:[[:space:]][[:digit:]]`
declare -i active_sink_index=`pacmd list-sinks | sed -n -e 's/\*[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`
declare -i major_sink_index=$sinks_count-1
declare -i next_sink_index=0

if [ $active_sink_index -ne $major_sink_index ] ; then
    next_sink_index=active_sink_index+1
fi

#change the default sink
pacmd "set-default-sink ${next_sink_index}"

#move all inputs to the new sink
 for app in $(pacmd list-sink-inputs | sed -n -e 's/index:[[:space:]]\([[:digit:]]\)/\1/p');
     do
         pacmd "move-sink-input $app $next_sink_index"
 done

ff setme default_sink $next_sink_index

#display notification
declare -i ndx=0
pacmd list-sinks | sed -n -e 's/device.description[[:space:]]=[[:space:]]"\(.*\)"/\1/p' | while read line;
do
    if [ $next_sink_index -eq $ndx ] ; then
        #notify-send -i notification-audio-volume-high "Sound output switched to" "$line"
        ff msg --id 8 -t "Sound output switched to $line"
        exit
    fi
    ndx+=1
done;

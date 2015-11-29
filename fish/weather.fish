#!/usr/bin/env fish

    #APIKEY is a global env variable obtained by signing up with api.openweathermap.org
    set query $argv[1]
    set units imperial
    # set data (echo curl -c ~/.cjar.txt "http://api.openweathermap.org/data/2.5/weather?q=$query&units=$units&APPID=$OPENWEATHERMAP_API_KEY")
    set data (curl -c ~/.cjar.txt "http://api.openweathermap.org/data/2.5/weather?q=$query&units=$units&APPID=bac8a5a60fbd408ddf03cc1dad480414")
    set temp (echo $data | jq '.main.temp')
    set desc (echo $data | jq '.weather' | grep description | cut -d ":" -f2 | cut -d '"' -f2)
    set sunshine 
    set rain a
    set snow a
    set cloudy  
    set foggy 
    echo $temp $desc


function ytube
    set a pick
    set pl techtalk
    set q ''
    set p 1
    set f v
    for i in (getvariables $argv)
        set val (splitwords-first-then-rest $i)
        set $val[1] $val[2]
    end
    switch $f
        case v
            set com mpv-wrap
        case a
            set com mpa
    end
    if exists $q
        set playlist_url (compose-youtube-search-query $q p=$p) 
        set -U ytube_last_query $playlist_url
    else
        set playlist_url (return-playlist-url $pl)
    end
    echo $playlist_url
    set data (get-youtube-html $playlist_url)
    set urls (get-urls-from-youtube $data)  
    set titles (get-titles-from-youtube $data)
    set choice (rfi match "choose a video: " $titles)
    set ndx (findindex $choice $titles)
    set url $urls[$ndx]
    set playlist $urls[$ndx..-1]
    switch $a
        case pick
            eval $com $url
        case startat
            eval mpv $playlist
    end
end

function get-range-of-youtube-pages
    set p 1
    set q ''
    set results ''
    for i in (getvariables $argv)
        set val (splitwords-first-then-rest $i)
        set $val[1] $val[2]
    end
    echo p is $p and q is $q
    # for i
end


function get-urls-from-youtube
    set data $argv
    set urls (apply-to-list return-youtube-url (echo $data | jq .url)) 
    println $urls
end

function get-youtube-html
    youtube-dl --netrc --flat-playlist -j "$argv" | jq .
end

function get-titles-from-youtube
    set data $argv
    set titles (echo $data | jq .title | fix-video-title)
    set titles (apply-to-list stripquotes $titles)
    println $titles
end

function retrieve-playlist-html
    youtube-dl --netrc --flat-playlist -j "$argv" | jq .
end

function compose-youtube-search-query
    set p 1
    set query (explode-words $argv[1])

    if test (count $argv) -gt 1

        for i in (getvariables $argv[2..-1])
            set val (explode $i)
            set $val[1] $val[2]
        end
    end
    
    set start 'https://www.youtube.com/results?search_query='
    set end "&page=$p"
    set middle ""
    for i in $query
        set middle {$middle}+$i
    end
    set middle (echo $middle | cut -c 2-)
    echo {$start}{$middle}$end
end

function fix-video-title
    while read -l line
        echo $line | sed 's*&#39;*\'*g' | sed 's#&quot;##g'
    end
end


function return-youtube-url
    if echo $argv | grep 'https://www.youtube.com/watch' > /dev/null
        echo \""$argv"\"
    else
        echo \""https://www.youtube.com/watch?v=$argv"\"
    end
end

function return-playlist-url
    if startswith @ $argv
        compose-youtube-search-query $argv[2..-1]
        return 0
    end
    set var youtube_playlist_$argv
    if exists $$var
        echo $$var
        return 0
    else
        set val (get-youtube-playlist $argv)
        echo $val
        set -U $var $val
    end
end

function get-youtube-playlist
    set dir (pwd)
    set tmp /tmp/ytd
    if not test -d $tmp
        mkdir $tmp
    end
    cd $tmp
    set -x useragent 'Mozilla/5.0 (X11; Linux x86_64; rv:41.0) Gecko/20100101 Firefox/41.0'
    youtube-dl -q --netrc --flat-playlist --write-pages --user-agent "$useragent" https://www.youtube.com/channel/UCr-n4_yU5HTw9rrGleWhFIg/ > /dev/null
    set file (here uur)
    set txt (cat $file | pup | grep $argv | pup 'json{}' | grep href | trim | cut -d "/" -f2 | cut -d '"' -f1)
    set url https://www.youtube.com/$txt
    cd $dir
    echo $url
end

function add-to-recent-videos
    set url "$argv"
    set title (given-url-get-title "$url")
    set url (quote $url)
    set entry $title $url
    set -U recent_videos (take 20 (unique (println "$entry" $recent_videos)))
end

function mpv-wrap
    switch (count $argv)
        case 1
            set vid $argv[1]
        case 2
        set vid $argv[-1]
        set opts $argv[1..-2]
        set opts (echo $opts | sed 's#-a#--no-video#g')
    end
    set com mpv
    add-to-recent-videos $vid
    eval $com $opts \"$vid\"
end

function recent-videos
    set entry (extract-url-from-entry (rfi match "pick video" (println $recent_videos)))
    eval mpv $entry
end

function extract-url-from-entry
    quote (echo "$argv" | cut -d '"' -f4)
end

function given-url-get-title
    youtube-dl --flat-playlist -j "$argv" | jq .fulltitle
end


al ym 'ytube q="$argv" f=a'
al yv 'ytube q="$argv" f=v'

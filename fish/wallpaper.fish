set -U wallpaperroot /mnt/ext/Images/backgrounds
set -U naughtypics /mnt/ext/Images/xrated

function wp

    for i in (getvariables $argv)
        set val (explode $i)
        set $val[1] $val[2]
    end
    
    set laststyle $bgstyle
    set -e bgstyle
    set -e bgimage

    switch $argv[1]
        case view
            pics $argv[2]
            return 0
        case edit
            gimp $bgimage
            wp $bgimage
            return 0
        case url
            file-bg-url $argv[2..-1]
            return 0
        case slideshow
            slideshow $argv[2..-1]
            return 0
        case ss
            slideshow $argv[2..-1]
            return 0
        case get
            switch $argv[2]
                case random
                    pick-list-from-wh $argv[3] sort=random
                case "*"
                    pick-list-from-wh $argv[2..-1]
            end
            return 0
        case file
            file-bg $argv[2..-1]
            return 0
        case save
            save-wp $argv[2]
            return 0
        case remove
            rm $bgimage
            return 0
        case xrated
            set backgrounddir $naughtypics
            set img (findall $backgrounddir jpg jpeg bmp png | shuf | head -1)
            set -U bgstyle xrated
        case any
            set backgrounddir $wallpaperroot
        case next
            if match $slideshowstatus play
                wp slideshow next
            else
                wp style $laststyle
            end
            return 0
        case rename
            set ext (get-ext $bgimage)
            set newname $argv[2]
            set path (cutlastn / 2- $bgimage)/$newname.$ext
            mv $bgimage $path
            wp $path
            return 0
        case img
            set -U bgstyle (cutlastn "/" 2 $argv[2])
            set -U bgimage $argv[2]
            wp $argv[2]
            return 0
        case style
            set backgrounddir (get-folder-for-backgrounds $argv[2])
            set img (findall $backgrounddir jpg jpeg bmp png | shuf | head -1)
            set -U bgstyle $argv[2]
        case "*"
            if test -f $argv[1]
                set img (pathof $argv[1])
            else
                return 1
            end

    end

    set -U bgimage $img

    if not exists $format
        set ratio (get-image-aspect-ratio-type $img)
        if not exists $ratio
            echo img is $img
            get-resolution $img
            get-aspect-ratio $img
        end
        switch $ratio
            case "narrow"
                set format max
            case "wide"
                set format scale
            case "superwide"
                convert -crop 50%x100% +repage $img /tmp/pano.jpg
                set img /tmp/pano-1.jpg /tmp/pano-0.jpg 
                set format max
        end
    end

    feh --bg-$format $img
    signal-i3blocks wallpaper
end

function list-backgrounds
    findall (get-folder-for-backgrounds $argv) jpg jpeg bmp png
end

function slideshow
        set time 30
        set ndx 1
        set interval minutes

        for i in (getvariables $argv)
            set val (explode $i)
            set $val[1] $val[2]
        end

        switch $argv[1]
            case add
                set -U backgroundslist $backgroundslist (pathof $argv[2])
            case category
                set -U backgroundslist (list-backgrounds $argv[2])
                if match $slideshowstatus paused
                    slideshow start
                end
            case remove
                set -U backgroundslist (without (pathof $argv[2]) $backgroundslist)
            case show
                if exists $backgroundslist
                    sxiv -tbfor $backgroundslist
                end
            case clear
                slideshow stop
                er backgroundslist
            case next
                if exists $backgroundslist
                    if not match $slideshowstatus paused
                        set -U currentbackgroundindex (math $currentbackgroundindex + 1)
                        if test $currentbackgroundindex -gt (count $backgroundslist)
                            set currentbackgroundindex 1
                        end
                        wp $backgroundslist[$currentbackgroundindex]
                    end
                end
            case prev
                if exists $backgroundslist
                    if not match $slideshowstatus paused
                        set -U currentbackgroundindex (math $currentbackgroundindex - 1)
                        if test $currentbackgroundindex -lt 1
                            set currentbackgroundindex (count $backgroundslist)
                        end
                        wp $backgroundslist[$currentbackgroundindex]
                    end
                end
            case pick
                set currentbackgroundindex (findindex $argv[2] $backgroundslist)
                wp $backgroundslist[$currentbackgroundindex]
            case test
                echo $hi
            case start
                if exists $backgroundslist
                    set -U currentbackgroundindex $ndx
                    set -U slideshowstatus play
                    wp $backgroundslist[$currentbackgroundindex]
                    switch $interval
                        case seconds
                            set seconds $time
                        case minutes
                            set seconds (math "$time * 60")
                        case hours
                            set seconds (math "time * 3600")
                    end
                    while not match $slideshowstatus stopped
                        sleep $seconds
                        wp slideshow next
                    end
                end
            case shuffle
                set backgroundslist (println $backgroundslist | shuf)
            case pause
                set -U slideshowstatus paused
            case stop
                set -U slideshowstatus stopped
            case continue
                slideshow next
                switch $slideshowstatus
                    case stopped
                        slideshow start ndx=$currentbackgroundindex
                    case play
                        nil
                    case paused
                        set -U slideshowstatus play
                        slideshow next
                end
    end
end

function pick-list-from-wh
    #set default values
    set cookies ~/.cjar.txt
    set purity 100
    set sort relevance
    set q $argv[1]
    set n 1
    set resolutions 1440x900,1600x900,1600x1200,1680x1050,1920x1080,1920x1200,2560x1440,2560x1600,3840x1080,5760x1080,3840x2160
    set wallhavengallery /tmp/wallhavengallery

    rm /tmp/wallhavengallery/* #get rid of the files from last run

    for i in (getvariables $argv)
        set val (explode $i)
        set $val[1] $val[2]
    end

    if test -f $cookies
        set curloptions -b
    end

    set img /tmp/wallhaven.jpg
    set url "http://alpha.wallhaven.cc/search?q=$q&categories=111&purity=$purity&resolutions=$resolutions&sorting=$sort&order=desc"
    set numbers (curl $curloptions $cookies $url | pup 'a[class=preview]' | grep href | head -$n | cut -d '"' -f4 | rev | cut -d "/" -f1 | rev)
    mkdir $wallhavengallery #in case it doesn't exist tmp may be in ram after all
    for i in (seq (count $numbers))
        set targetimage http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-$numbers[$i].jpg
        curl $curloptions $cookies $targetimage > $wallhavengallery/$i.jpg &
    end
    while pgrep curl > /dev/null
        sleep 0.25
    end
    if test $n -eq 1
        wp $wallhavengallery/1.jpg
    else
        pics $wallhavengallery
    end
end

function save-wp
    if file-bg $bgimage $argv
        set ext (get-ext $bgimage)
        set -U bgimage $wallpaperroot/$argv.$ext
    end
end

function stdincurl
    while read -l line
        curl $line
    end
end


function get-resolution
    identify $argv | sed "s#$argv##g" | trim | cut -d " " -f2
end

function get-aspect-ratio
    set res (get-resolution $argv)
    set height (echo $res | cut -d "x" -f2)
    set width (echo $res | cut -d "x" -f1)
    echo (wcalc -q "$width / $height")
end

function get-image-aspect-ratio-type
    #screw whomever doesn't handle floats in test
    set ratio (get-aspect-ratio $argv) 
    set integer (truncate-num (wcalc -q "$ratio * 100"))
    switchonval $integer 1-125 narrow 126-249 wide 250-900 superwide
end

function image-date
    identify -verbose 00046.jpg | grep DateTimeOriginal | cut -d ":" -f3- | trim
end

function getvariables
    if not substr "$argv" =
        return 1
    else
        set vars (println $argv | grep =)
        for i in $vars
            echo (echo $i | cut -d "=" -f1) (echo $i | cut -d "=" -f2)
        end

    end
end

function pics
    if exists $argv
        if test -d $argv
            set target $argv
        else
            set target (get-folder-for-backgrounds $argv)
        end
    else
        set target (pwd)
    end
    sxiv -tbfor $target &
end

function file-bg
    set file $argv[1]
    set target $argv[2]
    set ext (get-ext $file)
    set category (echo $target | cut -d "/" -f1)
    set name (echo $target | cut -d "/" -f2)
    set dir (get-folder-for-backgrounds $category)
    set location $dir/$name.$ext
    mv $file $location
    wp $location
end

function file-bg-url
    set url (xclip -o)
    set name $argv[1]
    set ext (get-ext $url)
    set tmp background-url.$ext
    curl $url > /tmp/$tmp
    cd /tmp
    file-bg $tmp $name
end

function get-folder-for-backgrounds
    switch $argv
        case xrated
            echo $naughtypics
        case "*"
            set res (find $wallpaperroot -type d | grep $argv | head -1)
            if not exists $res
                return 1
            else
                echo $res
            end
    end
end

function name-of-wallpaper
    cutlastn "/" 1 $bgimage | cut -d "." -f1 | sed "s/-/ /g"
end

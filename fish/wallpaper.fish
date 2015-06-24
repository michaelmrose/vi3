set -U wallpaperroot /mnt/ext/Images/backgrounds
set -U naughtypics /mnt/ext/Images/xrated

function wp

    if not exists $argv
        wp any
        return 0
    else if test -f $argv[1]
        wp img $argv
        return 0
    end

    #if no arguments choose a random background from all folders
    #if the first argument is a valid file set that 

    switch $argv[1]
        case view
            pics $argv[2]
            return 0
        case url
            file-bg-url $argv[2..-1]
            return 0
        case net
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
        case xrated
            set backgrounddir $naughtypics
        case any
            set backgrounddir $wallpaperroot
        case next
            wp $bgstyle
            return 0
        case img
            set img $argv[2]
            if test (count $argv) -eq 3
                set style $argv[3]
            end
        case "*"
            if test -f $argv[1]
                set img $argv[1]
                set style $argv[2]
            else
                set backgrounddir $wallpaperroot/$argv
            end
    end


    if not exists $backgrounddir
        set backgrounddir $wallpaperroot/$argv
    end

    if not exists $img
        set img (findall $backgrounddir jpg jpeg bmp png | shuf | head -1)
    end
    if not exists $style
        set ratio (get-image-aspect-ratio-type $img)
        if not exists $ratio
            echo img is $img
            get-resolution $img
            get-aspect-ratio $img
        end
        switch $ratio
            case "narrow"
                set style max
            case "wide"
                set style scale
            case "superwide"
                convert -crop 50%x100% +repage $img /tmp/pano.jpg
                set originalimage $img
                set img /tmp/pano-1.jpg /tmp/pano-0.jpg 
                set style max
        end
    end
    set -U bgstyle (cutlastn "/" 2 $img)
    if exists $originalimage
        set -U bgimage $originalimage
    else
        set -U bgimage $img
    end
    feh --bg-$style $img
end

function pick-list-from-wh
    #set default values
    set cookies ~/.cjar.txt
    set purity 100
    set sort relevance
    set q $argv[1]
    set n 1
    set wallhavengallery /tmp/wallhavengallery

    rm /tmp/wallhavengallery/* #get rid of the files from last run

    for i in (getvariables $argv)
        set val (explode $i)
        set $val[1] $val[2]
    end

    set img /tmp/wallhaven.jpg
    set url "http://alpha.wallhaven.cc/search?q=$q&categories=111&purity=$purity&resolutions=1440x900,1600x900,1600x1200,1680x1050,1920x1080,1920x1200,2560x1440,2560x1600,3840x1080,5760x1080,3840x2160&sorting=$sort&order=desc"
    set numbers (curl -b $cookies $url | pup 'a[class=preview]' | grep href | head -$n | cut -d '"' -f4 | rev | cut -d "/" -f1 | rev)
    mkdir $wallhavengallery #in case it doesn't exist tmp may be in ram after all
    for i in (seq (count $numbers))
        set targetimage http://wallpapers.wallhaven.cc/wallpapers/full/wallhaven-$numbers[$i].jpg
        curl -b $cookies $targetimage > $wallhavengallery/$i.jpg &
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
function gimpfromstdin
    while read -l line
        gimp $line
    end
end


function zoomsxiv
    set title (xprop -id (mywin) | grep NET_WM_NAME | cut -d "=" -f2- | trim | cut -d '"' -f2)
    if [ $title = sxiv ]
        xdotool key --delay 5 plus plus plus
    end
end

function pics
    if exists $argv
        if test -d $argv
            set target $argv
        else
            set target /mnt/ext/Images/backgrounds/$argv
        end
    else
        set target (pwd)
    end
    sxiv -tbfor $target &
end

function file-bg
    set file $argv[1]
    set name $argv[2]
    set ext (get-ext $file)
    set location /mnt/ext/Images/backgrounds/$name.$ext
    if test -f $location
        echo it already exists
        return 1
    else
        mv $file $location
    end
end

function file-bg-url
    set url (xclip -o)
    set name $argv[1]
    set ext (get-ext $url)
    set tmp background-url.$ext
    curl $url > /tmp/$tmp
    cd /tmp
    file-bg $tmp $name
    wp /mnt/ext/Images/backgrounds/$name.$ext
end

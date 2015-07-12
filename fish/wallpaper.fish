# wallpaper.fish by michael rose a nicer alternative to using feh hsetroot or such manually
# Usage to follow
# - wp $imagefile sets your wallpaper like feh (in fact it uses feh) with the added benefit that it will automatically determine what sort of scaling to use with the following rules
#   - narrow images use max so that they aren't oddly streched
#   - wide images are scaled to file the whole screen
#   - superwide images are split via imagemagick and corresponding images are displayed with max
#   - to manually set the style simply use wp $imagefile format=value wherein possible values include center fill max scale tile
# - wp style value will pick a random background from a subfolder of $wallpaperroot wherein the subfolder is named value and any number of levels under wallpaperroot and all files under it
# - wp view value will view all the pictures in the forementioned subfolder and any under it
# - wp edit will edit current background in gimp
# - wp url will get the url from the clipboard with xclip -o file it to the value passed in and set it as the bg
#   -I use this combined with a pentadacyl binding to bind <leader>b to prompt for a value then run this function with that value
# - wp get gets backgrounds from wallhaven 
#   - feel free to pass the following values in the format setting=value
#     - purity=nnn wherein each n can be either 0 or 1, first is safe for work, second is naughty, third is porn eg 100 is safe 001 is all porn all the time
#     - sort=relevance,random,date default relevance
#     - q your search query
#     - n number of results default is 1
#     - resolutions the resolutions you want the default is fairly inclusive
#     - if you ask for 1 it is set as your background otherwise you are shown all in a gallery
#   - if you want to enable interesting options in sxiv you can look at https://gist.github.com/michaelmrose/8c052ba76ad524ba2605
#     this lets you for example press <C-x><C-w> to set the current selected image as your wallpaper among other things
# - wp remove deletes the current background file
# - wp any chooses any of your backgrounds at random
# - wp rename self explanetory
# - wp save category/name saves the current background to category/name useful if you set your wp to something like a url you downloaded
# - wp prev next next or prev image in slideshow, more on that later
# - file-bg image style/name will move the image to whatever subdir style is named name
# - slideshow category will set all files in category to $backgroundslist wont start it if stopped but will if paused
# - slideshow show will use sxiv to show the current contents of $backgroundslist
# - slideshow add remove and clear are obvious but will be a lot nicer if you use custom actions in sxiv as you can simply
#   enter slideshow show mark a bunch and press a key to remove them or wp view category and add the ones you would like
# - slideshow next and prev are self explanetory note wraps around
# - slideshow shuffle shuffles the list
# - slideshow start stop pause continue work as expected
#   - you can pass values to slideshow start as follows
#     - ndx index to start on
#     - interval minutes seconds hours default is minutes
#     - time number of intervals to go between changing backgrounds default is 30
#
# in order for this to actually work consider the following
# - you may need functions from the rest of the repo particularly general.fish
# - you should set wallpaperroot and naughtypics to values that make sense for you
# - your backgrounds should all preferably be in wallpaperroot arranged in any number of unique subfolders
# - if you want to get pics from wallhaven 
#   - make sure you have pup installed to process html
#   - https://github.com/ericchiang/pup
#   - if you want to be able to and want to be able to see naughty pics create an acct and export your cookies to ~/.cjar.txt or whatever
# - spliting a super wide wallpaper between monitors requires imagemagick
# - viewing files uses sxiv a great minimal image viewer
# - wp url uses xclip
# - wp edit requires gimp
# - viewing images is handled with sxiv, I heartily recommend building it from source and changing tns->zl = 0 to 3 in thumbs.c so that the default isn't microscopic

set -U wallpaperroot /mnt/ext/Images/backgrounds
set -U naughtypics /mnt/ext/Images/xrated

function wallpaper

    for i in (getvariables $argv)
        set val (explode $i)
        set $val[1] $val[2]
    end
    
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
            wp style backgrounds
            return 0
        case similar
            wp style $bgstyle
            return 0
        case next
             slideshow next
            return 0
        case prev
            slideshow prev
            return 0
        case rename
            set ext (get-ext $bgimage)
            set newname $argv[2]
            set path (cutlastn / 2- $bgimage)/$newname.$ext
            mv $bgimage $path
            wp $path
            return 0
        case img
            set -U bgimage (pathof $argv[2])
            set -U bgstyle (cutlastn "/" 2 $bgimage)
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
                set perc (math 100 / (get-number-of-displays))
                convert -crop $perc%x100% +repage $img /tmp/pano.jpg
                for i in (get-display-order)
                    set lst $lst /tmp/pano-$i.jpg
                end
                set img $lst
                set format max
        end
    end

    feh --bg-$format $img
    if pgrep i3blocks > /dev/null
        signal-i3blocks wallpaper
    end
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
            case start
                if exists $backgroundslist
                    set -U currentbackgroundindex $ndx
                    set -U slideshowstatus playing
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
            case status
                echo $slideshowstatus
            case continue
                slideshow next
                switch $slideshowstatus
                    case stopped
                        slideshow start ndx=$currentbackgroundindex
                    case play
                        nil
                    case paused
                        set -U slideshowstatus playing
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

function get-display-left-to-right
    set outputs (xrandr | grep " connected" | cut -d " " -f1)
    set offsets (xrandr | grep " connected" | cut -d + -f2)
    set sorted (println $offsets | sort)
    for i in (seq (count $outputs))
        set x (findindex $sorted[$i] $offsets)
        set lst $lst $outputs[$x]
    end
    println $lst
end

function get-number-of-displays
    count (get-connected-displays)
end

function get-display-order
    set outputs (xrandr | grep " connected" | cut -d " " -f1)
    set ordered (get-display-left-to-right)
    for i in $outputs
        math (findindex $i $ordered) - 1
    end
end
function get-connected-displays
    xrandr | grep " connected" | cut -d "c" -f1 | trim
end

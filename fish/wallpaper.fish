set -U wallpaperroot /mnt/ext/Images/backgrounds
set -U naughtypics /mnt/ext/Images/xrated

function wallpaper

    #default values
    set norecord false

    for i in (getvariables $argv)
        set val (explode $i)
        set $val[1] $val[2]
    end

    if not exists $argv
        wp recent
        return 0
    end
    
    switch $argv[1]
        case view
            pics $argv[2]
            return 0
        case categories
            for i in (find $wallpaperroot -type d);cutlast / $i;end
            return 0
        case edit
            gimp $bgimage
            wp $bgimage
            return 0
        case url
            file-bg-url $argv[2..-1]
            return 0
        case recent
            sxiv -tbfor $recent_backgrounds 2> /dev/null
            return 0
        case cat
            move-current-wallpaper-to-category $argv[2]
            return 0
        case name
            name-of-wallpaper
            return 0
        case create
            create-wallpaper-category $argv[2..-1]
            return 0
        case album
            wp (album-art)
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
        case rm
            rm $bgimage
            set recent_backgrounds (remove-from-list $bgimage $recent_backgrounds)
            wp $recent_backgrounds[1]
            return 0
        case recall
            ~/.fehbg
            return 0
        case any
            wp style any
            return 0
        case similar
            wp style $bgstyle
            return 0
        case list
            println $recent_backgrounds
            return 0
        case clean
            set -U recent_backgrounds (println $recent_backgrounds | grep -v xrated)
            return 0
        case next
            wallpaper-next
            return 0
        case prev
            wallpaper-prev
            return 0
        case scale
            feh --bg-scale $bgimage
            return 0
        case max
            feh --bg-max $bgimage
            return
        case fill
            feh --bg-fill $bgimage
            return
        case count
            count (findall $wallpaperroot image)
            return 0
        case size
            du -hs $wallpaperroot
            return 0
        case rename
            file-bg $bgimage $bgstyle/$argv[2..-1]
            return 0
        case style
            set backgrounddir (get-folder-for-backgrounds $argv[2])
            echo bgd is $backgrounddir
            set img (findall $backgrounddir image | shuf | head -1)
            # set img (findall-list dirs=$backgrounddir types=jpg,jpeg,bmp,png | shuf | head -1)
            wp $img
            return 0
        case "*"
            if test -f $argv[1]
                set img (pathof $argv[1])
                set -U bgstyle (cutlastn "/" 2 $img)
            else
                return 1
            end

    end

    set -U bgimage $img
    if not match $norecord true
        add-to-recent-backgrounds $img
        set -U wallpaperindex 1
    else
    end
    cp $img /mnt/ext/Images/backgrounds/lightdm

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
                set format fill
            case "superwide"
                set perc (math 100 / (get-number-of-displays))
                convert -crop $perc%x100% +repage $img /tmp/pano.jpg
                for i in (get-display-order)
                    set lst $lst /tmp/pano-$i.jpg
                end
                set img $lst
                set format fill
        end
    end

    feh --bg-$format $img
    if pgrep i3blocks > /dev/null
        signal-i3blocks wallpaper
    end
end

function move-current-wallpaper-to-category
    move-wallpaper-to-category $argv $bgimage
end

function move-wallpaper-to-category
    set category $argv[1]
    set dest (get-folder-for-backgrounds $category)
    set files $argv[2..-1]
    for file in $files
        set name (cutlast / $file)
        mv $file $dest/$name
        if match $file $bgimage
            wp $dest/$name
        end
    end
end

function create-wallpaper-category 
    if substr $argv /
        set root (get-folder-for-backgrounds (echo $argv | cut -d / -f1))
        set name (echo $argv | cut -d / -f2)
    else
        set root $wallpaperroot
        set name $argv
    end
    mkdir $root/$name
end

# function move-wallpaper-prompt
#     if exists $argv
#         set acc $argv
#     else
#         while read -l line
#             set acc $acc $line
#         end
#     end
#     set category (rfi enter "enter a category: ")
#     echo move-wallpaper-to-category $category $acc
# end

function wallpaper-prev
    if not exists $wallpaperindex
        set -U wallpaperindex 1
    end
    set -U wallpaperindex (math $wallpaperindex + 1)
    if test $wallpaperindex -gt (count $recent_backgrounds)
        set -U wallpaperindex 1
    end
    wp $recent_backgrounds[$wallpaperindex] norecord=true
end

function wallpaper-next
    if not exists $wallpaperindex
        set -U wallpaperindex 1
    end
    set -U wallpaperindex (math $wallpaperindex - 1)
    if test $wallpaperindex -lt 1
        set -U wallpaperindex (count $recent_backgrounds)
    end
    wp $recent_backgrounds[$wallpaperindex] norecord=true
end

function list-backgrounds
    findall-list dirs=(get-folders-for-backgrounds $argv) types=jpg,jpeg,bmp,png exlude=xrated
end

function add-to-recent-backgrounds
    set -U recent_backgrounds (take 30 (unique (filter-with-expr is-an-image (existing-files (println $argv $recent_backgrounds)))))
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
                set img (pathof $argv[2])
                if not contains $img $backgroundslist
                    set -U backgroundslist $backgroundslist $img
                    echo adding $img to backgroundslist
                else
                    echo already in there
                end
            case category
                set -U backgroundslist (list-backgrounds $argv[2])
                if match $slideshowstatus paused
                    slideshow start
                end
            case remove
                set -U backgroundslist (without (pathof $argv[2]) $backgroundslist)
            case show
                if exists $backgroundslist
                    sxiv -tbfor $backgroundslist 2> /dev/null
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
    ensure-dir-exists $wallhavengallery
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
    switchonval $integer 1-132 narrow 133-249 wide 250-900 superwide
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
            # echo (echo $i | cut -d "=" -f1) (echo $i | cut -d "=" -f2)
            set var (echo $i | cut -d "=" -f1)
            set val (echo $i | cut -d "=" -f2 | sed 's/,/ /g')
            echo $var $val
        end

    end
end

function pics
    if exists $argv[1]
        if test -d $argv[1]
            set target $argv[1]
        else
            set target (get-folder-for-backgrounds $argv[1])
        end
    else
        pics (pwd)
    end
    # set pictures (findall-list dirs=$target types=jpg)
    
    #write something more complicated later
    switch (count $argv)
        case 1
            sxiv -tbfor $target 2> /dev/null
        case 2
            sxiv -tbfo $target/* 2> /dev/null
    end
end

function file-bg
    set file $argv[1]
    set target $argv[2]
    set ext (get-ext $file)
    set category (echo $target | cut -d "/" -f1)
    set name (echo $target | cut -d "/" -f2)
    set dir (get-folder-for-backgrounds $category)
    # if not exists $dir
    #   return 1
    # end
    set location $dir/$name.$ext
    mv $file $location
    wp $location
    touch $wallpaperroot/checksums/(checksum-simple $file)
end

function file-bg-url
    set url (xclip -o)
    set name $argv[1]
    set ext (get-ext $url)
    set tmp background-url.$ext
    curl $url > /tmp/$tmp
    cd /tmp
    if is-background-unique $tmp
      file-bg $tmp $name
    else
      echo background already exists
    end
end

function get-folder-for-backgrounds
    if match $argv any
        echo $wallpaperroot
        return 0
    end
    set res (find $wallpaperroot -type d | grep $argv | head -1)
    if test (count $res) -ne 1
        return 1
    else
        echo $res
    end
end

function get-folder-for-backgrounds2
    shortest (explode (get-folders-for-backgrounds $argv))
end

function get-folders-for-backgrounds3
    set res (find $wallpaperroot -type d | grep $argv)
    if not exists $res
        return 1
    else
        echo $res | sed 's/ /,/g'
    end
end

function name-of-wallpaper
    set category (cutlastn / 2 $bgimage)
    set name (cutlastn / 1 $bgimage | cut -d "." -f1 | sed "s/-/ /g")
    echo $category: $name
end

function show-wallpaper-category
    cutlastn / 2 $bgimage
end

function checksum-simple
  md5sum $argv | cut -d " " -f1
end

function is-background-unique
  not test -f $wallpaperroot/checksums/(checksum-simple $argv)
end

function checksum-all-backgrounds
  rm $wallpaperroot/checksums/*
  set images ''
  set checksums ''
  for i in (findall $wallpaperroot image)
    set csum (checksum-simple $i)
    set images $images $i
    set checksums $checksums $csum
    touch $wallpaperroot/checksums/$csum
  end
  set -U background_list $images
  set -U background_checksums $checksums
end

function find-all-duplicate-backgrounds
  checksum-all-backgrounds
  set acc ''
  set duplicates ''
  for i in (findall $wallpaperroot image)
      if contains (checksum-simple $i) $acc
        set line $i is the same as (given-checksum-return-filename (checksum-simple $i))
        set duplicates $duplicates "$line"
      end
      set acc $acc (checksum-simple $i)
  end
  println $duplicates
end

function given-checksum-return-filename
  set n (findindex $argv $background_checksums)
  echo $background_list[$n]
  # zip-lists $checksums $images
end
function zip-lists
  set size (math (count $argv) / 2)
  for i in (seq $size)
    echo $argv[$i] $argv[(math $i + $size)]
  end
end
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

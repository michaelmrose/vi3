set query blah
set filenames blah

function reload-config
    source ~/.config/fish/config.fish
    source /opt/vi3/fish/utilities.fish
    source /opt/vi3/fish/vi3.fish
    source /opt/vi3/fish/books.fish
    source /opt/vi3/fish/general.fish
    source /opt/vi3/fish/audio.fish
    source /opt/vi3/fish/mime.fish
end

function scd
    set numargs (count $argv)
    switch $numargs
        case "1"
            cd $argv
        case "2"
            cd (echo (pwd) | sed "s/$argv[1]/$argv[2]/g")
   end
end

alias c scd

alias rl reload-config

function ip3
    ipython3 qtconsole --colors=linux --ConsoleWidget.font_family="DejaVu Sans Mono" --ConsoleWidget.font_size="12"
end

function ip2
    ipython qtconsole --colors=linux --ConsoleWidget.font_family="DejaVu Sans Mono" --ConsoleWidget.font_size="12"
end

function theend
    sudo shutdown -h now
end

function rboot
    sudo shutdown -r now
end

function u
    cd ..
end

function fizzbuzz
    for i in (seq $argv)
        set result ""
        if divisible $i 3
            set result {$result}fizz
        end
        if divisible $i 5
            set result {$result}buzz
        end
        if match $result ""
            echo $i
        else
            echo $result
        end
    end
end

function reset-net
    sudo ifconfig eth0 down
    sleep 3
    sudo ifconfig eth0 up
end

function h
    cd ~
end

function die
    xkill
end

function logoff
    i3-msg exit
end


function kill-user
    sudo pkill -KILL -u $argv
end

function tm
    time $argv    
    echo " "
end

function logout
    i3-msg exit
end



function grepproc
    ps -A | grep $argv
end

function serv
    sudo /etc/init.d/$argv[1] $argv[2]
end

function service-list
    ls /etc/init.d/
end

function freespin
    sudo /opt/bin/revoco free
end

function clickit
    sudo /opt/bin/revoco click
end

function uz
    for i in $argv
        atool -x $i
    end
end

function v
    qvim $argv
end

function vs
    qvim -S ~/.vim/sessions/{$argv}
end

function ffs
    firefox
    sleep 2
    xdotool type ":sessionload $argv"
    xdotool key Return 
end

function session-load
    restoreme $argv
end

function session-edit
    qvim ~/sessions/{$argv}
end

function vimcloj
    session-load $argv
    vs $argv
    konsole --workdir /home/michael/proj/clojure/{$argv} -e lein repl
end

function ins
    sudo apt-get install $argv
end

function upg
    sudo apt-get upgrade $argv
end

function kill-last
    kill -9 %1
end

function pstatus
    apt-cache policy $argv
end

function aptup
    sudo apt-get update
end

function psearch
    apt-cache search $argv
end

function repo
    sudo add-apt-repository $argv
    aptup
end

function ppa
    sudo add-apt-repository ppa:$argv
    aptup
end

function here
    ls -A | grep -i $argv
end

function unins
    sudo apt-get remove $argv
end

function cs-compile
    ~/clojurescript/bin/cljsc $argv[1] '{:optimizations :advanced}' > $argv[2]
end

function version-info
    cat /etc/linuxmint/info
    cat /etc/*-release
end

function lclj
    zathura /home/michael/calibre/tech/Amit\ Rathore/Clojure\ in\ Action\ 2E\ MEAP\ version\ 06\ \(1244\)/Clojure\ in\ Action\ 2E\ MEAP\ version\ 06\ -\ Amit\ Rathore.pdf &
    idea
end

function pdfextract
    pdftk A=$argv[1] cat A$argv[2]-$argv[3] output temp.pdf
    mv temp.pdf $argv[1]
end

function pdfkillcover
    pdfextract $argv[1] 2 end
end

function coverit
   set url (xclip -o)
   wget $url --output-document=cover
   convert cover cover.pdf
   rm cover
   pdftk cover.pdf $argv cat output temp.pdf
   mv temp.pdf $argv
end

function replace-cover
    pdfkillcover $argv
    coverit $argv
end

function winclass
    xprop -id (mywin) | grep WM_CLASS | cut -d '"' -f4 
end

function wtfisthis
    whoami
    echo \n
    version-info
    echo \n
    inxi -Sxx
end

function ctof
    set temp $argv[1]
    set temp (math "$temp * 1.8 + 32")
    # echo $argv º celcius is $temp º fahrenheit
    echo {$temp}º 
end

function pdftoimages
    pdftk $argv burst
    for i in (ls *.pdf)
        set fname (extractfilename $i)
        convert $i $fname".png"
    end

    rm *.pdf
end

function extractfilename
    echo $argv | cut -d '.' -f1
end

function msg
    twmnc $argv
end

alias netflix netflix-desktop

# . /opt/fish/standard.fish

#--------------------------------------------------------------------------
# git stuff
#--------------------------------------------------------------------------
function gl
    git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%C(bold blue)<%an>%Creset' --abbrev-commit
end

function gc
    git commit $argv
end

function gsb
    git submodule $argv
end

function gs
    git status
end

function cclass
    startvm Compilers 
    mountccl  
    qvim ~/devvm
end
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
#ssh stuff
#--------------------------------------------------------------------------
function mountccl
    sshfs ccl:/home/compilers ~/devvm -o Compression=no -o Ciphers=arcfour
end

function umountccl
    fusermount -u ~/devvm
end

function startvm
    vmrun start ~/vmware/$argv/$argv.vmx
end

function suspendvm
    vmrun suspend ~/vmware/$argv/$argv.vmx
end
#--------------------------------------------------------------------------

function coursedl
    coursera-dl -d ~/courses $argv
end

function noteit
    qvim
    sleep 0.5
    xdotool key e space s n n
end

function vlcclip
    vlc (xclip -o)
end

function vplugname
    echo $argv | cut -d "/" -f5
end

function vimplug
    set dir (pwd)
    cd ~/.vim
    git submodule add $argv ./bundle/(vplugname $argv) 
    cd $dir
end 

function fadetoblack
    kdmctl kdm stop
end

function trackedvplug
    cat .gitmodules | grep path | cut -d "/" -f2
end

function gcal
    # google calendar add "{$argv}"
    gcalcli --calendar 'michael@rosenetwork.net' quick $argv
end

function work
    gcal "work $argv"
end

function gcalendar
    chromeless -new-window calendar.rosenetwork.net &
end

function fm
        set startingdir (pwd)
        j $argv
        open (pwd) &
        cd $startingdir
end

function keyp
    xdotool key $argv
end

function open-trans
    eval $argv[1]
    sleep 1
    set mywin (xdotool getactivewindow)
    transset -i $mywin $argv[2]
end

function trans
    currentapp
    transset -i $mywin $argv
end

function another-trans
    transset -i (xdotool getactivewindow) .{$argv}
end

function currentapp
    set -U mywin (xdotool getactivewindow)
end

function mywin
   xdotool getactivewindow
end

function transparent
    currentapp
    transset -i $mywin .86
end

function solid
    currentapp
    transset -i $mywin 1.0
end

function nextwindow
    set currentclass (xprop -id (mywin) | grep WM_CLASS | cut -d '"' -f4)
    nextmatch $currentclass
end

function chromeless3
    firefox -P chromeless -no-remote $argv &
    sleep 3
    unset-fullscreen
end

function chromeless2
    firefox -new-window $argv
    sleep 3
    keyp colon c h r o m e l e s s Return Control+z
end

function chromeless
    chromium-browser --kiosk $argv
end
    
function arrangeme
    if not pgrep urxvt
        urxvtc &
    end
    focus class firefox
    mws k
    focus class dolphin
    mws d
    focus class qvim
    mws j
    focus class urxvt
    mws f
    focus class hexchat
    mws a
    i3-msg workspace k
    i3-msg workspace a
end

function pman
    set app $argv
    if man $app > /dev/null
        man -t $app | ps2pdf - /tmp/{$app}.pdf
        open /tmp/{$argv}.pdf &
    else
        msg "no manual for $app"
    end
end

function display-manual
    pman (winclass)
end

function why
    set pkg (dpkg -S (which $argv))
    if exists $pkg
        set pkg (echo $pkg | cut -d ":" -f1)
        set result (apt-cache search $pkg | grep "^$pkg - ")
        echo $argv was installed as part of $result
    else
        echo $argv is not part of a package
    end
end

function depends-on
    apt rdepends $argv
end

function fz
    fzf -1 -q "$argv" | pipetest | openpipe
end

function fe
  set tmp $TMPDIR/fzf.result
  fzf --query="$argv[1]" --select-1 --exit-0 > $tmp
  if [ (cat $tmp | wc -l) -gt 0 ]
    set -U fquery (cat $tmp)
  end
end

function fp
  set tmp $TMPDIR/fzf.result
  set ph ""
  while read -l line
    echo $line | fzf > $tmp
    set ph $ph $line
  end
  echo $ph | fzf > tmp
  # fzf --query="$argv[1]" --select-1 --exit-0 > $tmp
  if [ (cat $tmp | wc -l) -gt 0 ]
    set -U fquery (cat $tmp)
  end
end

function blist
    echo in title
    calibredb list -s title:$argv
    echo in tag
    calibredb list -s tag:$argv
end

function badd
    calibredb add $argv
end

function bsrch
    calibredb list -s $argv
end

function updatebookdb
     sudo updatedb -o /home/michael/calibre/books.db -U /home/michael/calibre
end

function updateallbookdb
    updatebookdb tech-select
    updatebookdb fiction
end

function save-layout
    i3-save-tree --workspace (getCurrentWorkspace)   > ~/workspace.json
end

function sxivd
    sxiv *.png *.bmp *.jpg
end

function imgur-upload
    set img (imgur --anon upload $argv| grep imgur_page | cut -d ":" -f2-3 | trim)
    open $img
    echo $img
    echo $img | xclip -i -selection clipboard
end

set PATH /opt/vi3/bin /opt/bin /opt/dmenu /opt/scala/bin /opt/vim-qt/bin $PATH ~/scripts ~/racket/bin /opt/cxoffice/bin ~/games/dustaet/
if test -f /home/michael/.autojump/etc/profile.d/autojump.fish; . /home/michael/.autojump/etc/profile.d/autojump.fish; end

function bind-keys
    killall sxhkd
    sxhkd -c ~/keybindings/$argv &
end

function xcow
    xcowsay $argv --cow-size=large --monitor=0 --at=100,0 --font="DejaVu Sans Mon 60"
end

function er
    set -e $argv
end

function filtermatch
    set fexpr $argv[1]
    set match $argv[2]
    for i in $$argv[3]
        set val (echo $i | sed 's/(/\\\(/g' | sed 's/)/\\\)/g')
        set toeval $fexpr $val
        set result (eval $toeval)
        if match $result $match
            echo $i
            set acc $acc $i
        end
    end
    echo $acc
end


function has
    set target $argv[1]
    for i in $$argv[2]
        echo $i
        set acc $acc (tolower $i)
    end
    println $acc
end


function replace-str
    set numargs (count $argv)
    if test $numargs -gt 2
            echo $argv[3..-1] | sed "s/$argv[1]/$argv[2]/g"
    else
        while read -l line
            echo $line | sed "s/$argv[1]/$argv[2]/g"
        end
    end
end

function testf
    set ndx $argv[1]
    for i in $$argv[2]
        echo $i
    end
end

function removespaces-from-fnames
        for i in (ls)
            mv $i (echo $i | sed 's/ //g')
        end
end

function show-winclass
    msg (winclass)
end    

function update-calibre
    sudo python -c "import sys; py3 = sys.version_info[0] > 2; u = __import__('urllib.request' if py3 else 'urllib', fromlist=1); exec(u.urlopen('http://status.calibre-ebook.com/linux_installer').read()); main()"
end

function list-books
    set files (ls)
    filter files pdf
    filter files epub
end

function indexof
    set ndx (math "$argv[1] + 1")
    set cnt 1
    for i in $$argv[3]
        if test $ndx -eq $cnt 
            echo $i
            return 0
        else
            inc cnt
        end
    end
end

function snip
    set cnt 1
    set cutcom "cut "
    set str $argv[1]
    set ops $argv[2..-1]
    for i in $ops
        if divisible $cnt 2
            set cutcom "$cutcom -f$i | cut "
        else
            set cutcom "$cutcom - \"$i\" "
        end
        inc cnt
    end
    set cutcom $cutcom -f1-
    set mycom "echo $str | $cutcom" 
    # echo $mycom
    eval $mycom
end

function mth
    set varname $argv[1]; set varvalue $$argv[1]; set opstring $argv[2]
    set expression (echo "set $varname (math \"$opstring\")" | sed "s/self/$varvalue/g")
    eval $expression
    echo $$argv[1]
end

function mwrapwrap
    eval mthwrap
end

function mthwrap
    set cnt 1
    echo (mth cnt "self+3")
end

function inc
    mth $argv[1] "self+1"
end

function incr
    math $argv +1
end

function mth2
    math "$argv"
    set val (math $val + 1)
    set val (inc $val)
end

function choose
    switch $argv
        case "java"
            sudo update-alternatives --config java
        case "scala"
            set versions (ls /opt | grep scala-2)
            echo $versions | pipeit fuzzymenu
            if test (sizeof $fquery) -gt 0
                sudo rm /opt/scala
                sudo ln -s /opt/$fquery /opt/scala
            else
                echo not a valid choice
            end
    end
end

function sizeof
    echo (expr length $argv)
end

function myemail
    git config user.email
end

function turnitin
    set dir (pwd)
    cpr

    if [ $argv[1] = 'pw' ]
        echo $argv[2] > .pw
    else
        set email (myemail)
        set pw (cat .pw)
        echo sbt submit $email $pw
    end

    cd $dir
end

function cd-project-root
    if [ (pwd) = "/" ]
        return 1
    end
    if not test -d .git
        cd .. 
        cd-project-root
    else
        return 0;
    end
end

alias cpr cd-project-root 

function get-filename
    echo (cutlast "/" $argv) | cut -d "." -f1
end

function extract-filename
    if exists $argv
        get-filename $argv
    else
        while read -l line
            echo $line | pipeit get-filename
        end
    end
end

function za
    set ft (extract-filetype $argv)
    set fn (extract-filename $argv)
    set pth (pwd)
    set title (echo (cutlast "/" $argv) | cut -d "." -f1 | cut -d "-" -f1 | cut -d "(" -f1 | trim)
    set target ~/.converted/{$pth}/{$fn}.pdf
    # add-to-recent-reads $title 

    switch $ft
        case "pdf"
            zathura $argv
        case "epub"
            if not test -f $target
              ebook-convert "$argv" "$target"
            end
            zathura $target
    end
end

function really-quit
    xkill -id (mywin)
end

function pinfo-choose
    set pkgs (psearch $argv)
    switch (count $pkgs)
        case "1"
            pinfo $pkgs
        case "*"
            fuzzymenu $pkgs
            pinfo (echo $fquery | cut -d "-" -f1)
    end
end

function pinfo
    set pkgs (psearch $argv)
    for i in $pkgs 
        set info (pstatus (extract-package-name $i))
        set name (echo $info | cut -d ":" -f1)
        set desc (extract-package-description $i)
        set insvers (echo $info | cut -d " " -f5-6 | trim)
        set canidatevers (echo $info | cut -d " " -f9 | trim)
        if [ $insvers = $canidatevers ]
            set versions $canidatevers
        else
            set versions $insvers $canidatevers
        end
        echo -e {$white} $name - $desc Versions: $versions
    end
end

function extract-package-name
    echo $argv | cut -d " " -f1
end

function extract-package-description
    echo $argv | cut -d " " -f3-
end

function switch-library
    calibre -s
    calibre --with-library ~/calibre/$argv --detach & 
end

function honey-i-shrunk-the-window
    i3-msg floating enable
    xdotool getactivewindow windowsize 1 1
    transset -i (xdotool getactivewindow) 0.0
end

function look-no-window
    xterm -hold -e honey-i-shrunk-the-window
end

function focus-distinct
    set current_class (winclass)
    set current_id (mywin)
    while true
        im focus $argv
        set next_class (winclass)
        if not match $current_class $next_class
            set new_id (mywin)
            break
        end
    end
    focus id $current_id
    focus id $new_id
end        

function starton
    set ws $argv[1]
    set program $argv[2..-1] &
    set num (instances-of $program)
    ws $ws
    eval $program &
    while test (instances-of $program) -le $num
        sleep 0.25
    end
end

function instances-of
    count (wmctrl -lxp | grep -i $argv)
end


function window-exists
    set result (xwininfo -tree -root | grep $argv)
    if exists $result
        return 0
    else
        return 1
    end
end

function runningp
    set app $argv[1]
    set com bash -c \"pgrep $app\" \> /dev/null
    switch (count $argv)
        case 1 #ex runningp app
            eval $com
        case 3 #ex runningp app on host
            set host $argv[3]
            ssh $host -q -t "$com"
        case 4 #ex runningp app local or host
            set host $argv[4]
            test (runningp $app) -o (runningp $app on $host)
    end
end


function xc
    xclip -o
end

function ensure-started
    if not runningp $argv
        bash -c $argv &
    end
    while not pgrep $argv
    end
end

function urxvtt
    if not pgrep urxvtd
        urxvtd &
    end
    while not pgrep urxvtd
    end
    urxvtc
end

alias libprs500 calibre

#colors
set red    '\e[0;31m'
set blue   '\e[0;34m'
set green  '\e[0;32m'
set cyan   '\e[0;36m'
set purple '\e[0;35m'
set nc     '\e[0m'
set white  '\e[0;37m'

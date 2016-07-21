function match-seq
    set frst 1
    set scnd 2
    for i in $argv
        if not match $argv[$frst] $argv[$scnd]
            return 1
        else
            set frst (incr $frst)
            set scnd (incr $scnd)
            if test $scnd -gt (count $argv)
                return 0
            end
        end
    end
end

function match
    # expr match (tolower $argv[1]) (tolower $argv[2]) > /dev/null
    if [ (tolower $argv[1]) = (tolower $argv[2]) ]
    end
end

function tolower
    echo $argv | tr '[:upper:]' '[:lower:]'
end

function println
    for i in $argv
        echo -e $i
    end
end

function condense
    set acc ""
    for i in $argv; set acc $acc$i; end
    echo $acc
end

function foreach
    set fn $argv[1]
    for i in $argv[2..-1]
        eval $fn $i
    end
end

function trim
    if exists $argv
        echo $argv | sed -e 's/^ *//' -e 's/ *$//'
    else
        while read -l line
            # echo $line | sed 's/ *$//'
            echo $line | sed -e 's/^ *//' -e 's/ *$//'
        end
    end
end

function pipetest
    while read -l line
        echo $line
    end
end

function openpipe
    while read -l line
        open $line &
    end
end

function apply
    set fn $argv[1]
    for i in $$argv[2]
        set value (echo $i | sed 's/(/\\\(/g' | sed 's/)/\\\)/g')
        set toeval $fn '$value'
        set result (eval $toeval)
        set acc $acc $result
    end
    println $acc
end

function pipeit
    while read -l line
       set foo $argv $line
       eval $foo
    end
end


function fuzzymenu
    set acc ""
    for i in $argv
        set acc $acc \n $i
    end

    set tmp /tmp/fzf.result
    echo $acc | fzf > $tmp
    if [ (cat $tmp | wc -l) -gt 0 ]
        set choice (echo (cat $tmp) | trim)
    end
    set -g fquery $choice
    # echo $choice
end

function escape-spaces
    echo $argv | sed 's/ /\\ /g'
end

function endofpath
    echo (cutlast '/' $argv)
end

function cutlast
    set sep $argv[1]
    set lst $argv[2..-1]
    echo $lst | rev | cut -d "$sep" -f1 | rev
end

function cutlastn
    set sep $argv[1]
    set num $argv[2]
    set lst $argv[3..-1]

    echo $lst | rev | cut -d "$sep" -f$num | rev
end


function substr
    set e1 (tolower $argv[1])
    set e2 (tolower $argv[2])
    expr match $e1 .\*$e2.\* > /dev/null
end

function filter
    set filtertext $argv[2]
    for i in $$argv[1]
        if substr $filtertext $i
            set acc $acc $i
        end
    end
    println $acc
end

function exists
    if test (count $argv) -gt 0
        for i in $argv
            if test (sizeof $i) -gt 0
                return 0
            end
        end
    end
end

function findall
    if test -d $argv[1]
        set loc $argv[1]
        set lst $argv[2..-1]
    else
        set loc './'
        set lst $argv
    end
    switch $lst
        case image
            set lst bmp png jpg jpeg
        case video
            set lst mpv mpeg mkv avi wmv mp4
        case music
            set lst wma mp3 flac ogg wav
    end
    set start "find $loc "
    set second '-regextype posix-extended -regex ".*\.('
    set ending ')"'
    set pipe '|'
    for i in $lst
        set middle $i $pipe $middle
    end
    set middle (condense $middle)
    set middle (echo $middle | rev | cut -d '|' -f2- | rev)
    eval (condense $start $second $middle $ending)
end


function make-request-payload
    set val ''
    for i in $argv
        # echo i is $i and $$i
        set val $val$i=$$i\&
    end
    # echo v is $val
    set val (shorten-string 1 $val)
    echo $val
end

function shorten-string
    set str $argv[2..-1]
    set initialsize (sizeof $str)
    set toremove $argv[1]
    set size (math $initialsize - $toremove)
    echo $str | cut -c1-$size
end

function date-not-past
    set currentdate (date +%j)
    set date (convert-date-to-day-of-year $argv)
    set diff (math "$date - $currentdate")
    if test $diff -lt -300
        set date (math $date + 365)
    end
    test $date -ge $currentdate
end

function convert-date-to-day-of-year
    date -d "$argv" +%j
end


# function findall2
#     if [ $argv[1] = -p ]
#         set target $argv[2]
#         set types $argv[3..-1]
#     else
#         set target (pwd)
#         set types $argv
#     end

#     set pth (pwd)
#     cd $target
#     set start 'find ./ -regextype posix-extended -regex ".*\.('
#     set ending ')"'
#     set pipe '|'
#     for i in $types
#         set middle $i $pipe $middle
#     end
#     set middle (condense $middle)
#     set middle (echo $middle | rev | cut -d '|' -f2- | rev)
#     set results (eval (condense $start $middle $ending))
#     cd $pth
#     println $results

# end

function findall-list
    for i in (getvariables $argv)
        set val (explode $i)
        set $val[1] $val[2..-1]
    end

    for i in $dirs
        set results $results (findall $i $types)
    end
    if exists $exclude
        println $results | grep -v $exclude
    else
        println $results
    end
end

function cond
    if eval $argv[1]
        eval $argv[2]
    else
        eval $argv[3]
    end
end

function nil
end

function empty
    if [ $argv = "" ]
        return 0
    else
        return 1
    end
end

function divisible
    test (math "$argv[1]%$argv[2]") -eq 0
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

function endswith
    set lst (echo $argv[2..-1] | rev)
    startswith $argv[1] $lst
end

function unique
    for i in $argv
        if not contains $acc $i
            set acc $acc $i
        end
    end
    println $acc
    # println $argv | sort -u
end


function lastchar
    echo $argv | cut -c(sizeof $argv)
end

function hours
    date '+%H'
end

function within
    set num (truncate-num $argv[2])
    set min (echo $argv[1] | cut -d "-" -f1)
    set max (echo $argv[1] | cut -d "-" -f2)
    test $num -ge $min -a $num -le $max
end

function truncate-num
    switch (count $argv)
        case 1
            echo $argv | cut -d "." -f1
        case "*"
            set places $argv[-1]
            set wholenumber (echo $argv[1..-2] | cut -d "." -f1)
            set dec (echo $argv | cut -d "." -f2- | cut -c1-$places)
            echo {$wholenumber}.{$dec}
   end
end

function is-even
    test (modulo $argv 2) -eq 0
end

function is-odd
    test (modulo $argv 2) -ne 0
end

function modulo
    math "$argv[1] % $argv[2]"
end

function odds
    for i in (range (count $argv))
        if is-odd $i
            set acc $acc $argv[$i]
        end
    end
    println $acc
end

function evens
    for i in (range (count $argv))
        if is-even $i
            set acc $acc $argv[$i]
        end
    end
    println $acc
end

function uid
    uuidgen
end

function greaterof
    if test $argv[1] -gt $argv[2]
        echo $argv[1]
    else
        echo $argv[2]
    end
end

function take
    set lst $argv[2..-1]
    for i in (range (lesserof $argv[1] (count $lst)))
        echo $lst[$i]
    end
end

function lesserof
    if test $argv[1] -lt $argv[2]
        echo $argv[1]
    else
        echo $argv[2]
    end
end

function switchonval
    set val $argv[1]
    set tail $argv[2..-1]
    set ranges (odds $tail)
    set results (evens $tail)
    for i in (seq (count $ranges))
        if within $ranges[$i] $val
            echo $results[$i]
        end
    end
end


function randomroll
    switch $argv[1]
        case binary
            rand -M 2
        case select
            set lst $argv[2..-1]
            set num (randomroll (count $lst))
            echo $lst[$num]
        case fromzero
            set num (randomroll $argv[2])
            math $num - 1
        case "*"
            set num $lastroll
            while test $num -eq $lastroll
                set num (rand -M $argv)
                set $num (math $num + 1)
            end
            math $num + 1
            set -U lastroll $num
    end

end

function test-recursion
    if exists $argv
        set depth (math $argv + 1)
    else
        set depth 1
    end
    echo depth is $depth
    recursive $depth
end

function isinteger
    echo $argv | grep -E '^[0-9]+$' > /dev/null
end

# function waituntilfocused
#     #holds until a new window is focused of the chosen windowclass"
#     set winid (xdotool getactivewindow)
#     while [ (xdotool getactivewindow) = $winid ]
#     end
#     while not [ (winclass) = $argv ]
#     end
# end
#
# function every-n-line
#     set num $argv[1]
#     set lst $argv[2..-1]
#     set sedstr (echo \'n;x;p\' | sed "s/x/$num/g" )
#     println $argv | sed -n $sedstr
# end
function waituntilfocused
    #holds until a new window is focused of the chosen windowclass"
    set winid (wininfo id dec)
    
    while [ (wininfo id dec) = $winid ]
    end

    while not [ (wininfo class) = $argv ]
    end
end

function waituntilfocusedsame
    while not [ (winclass) = $argv ]
    end
end

function without
    set val $argv[1]
    set lst $argv[2..-1]
    for i in $lst
        if not match $val $i
            echo $i
        end
    end
end

function pathof
    set partialpath (pwd)/$argv
    set fullpath $argv
    if test -f $partialpath
        echo $partialpath
    else if test -f $fullpath
        echo $fullpath
    else
        echo not a file!
    end
end

function here
    ls -A | grep -i $argv
end

function winclass
    xprop -id (wininfo id dec) | grep WM_CLASS | cut -d '"' -f4
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

function sizeof
    echo (expr length $argv)
end

function get-ext
    if exists $argv
        cutlast . "$argv"
    else
        while read -l line
            get-ext $line
        end
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

function findindex
    set target $argv[1]
    set list $argv[2..-1]
    set cnt 1
    for i in $list
        if [ $i = $target ]
            echo $cnt
            return 0
        else
            set cnt (math "$cnt + 1")
        end
    end
end

function fed
    switch $argv[1]
        case "-i"
            funced -i $argv[2..-1]
        case "*"
            set fname $argv[1]
            set file (defined-in $fname)
            set line (ag "function $fname -d|function $fname\$" $file | cut -d ":" -f1)

            nvim +$line $file
    end
end

function get-line-of-fn-definition
    set fname $argv[1]
    set file (defined-in $fname)
    echo (ag "function $fname -d|function $fname\$" $file | cut -d ":" -f1)
end

function defined-in
    set fn "function $argv\$"
    set fn2 "function $argv -"
    set al "alias $argv "
    set fishpaths /opt/vi3/fish ~/fish ~/.config/fish/functions
    set fishconfig ~/.config/fish/config.fish
    for i in $fishpaths
        set results $results (ag -f $fn $i | cut -d ':' -f1)
        set results $results (ag -f $fn2 $i | cut -d ':' -f1)
        set results $results (ag -f $al $i | cut -d ':' -f1)
    end

    echo $results[1]
    set -e results
end

function defined
    type $argv > /dev/null
end

function seperate
    set ndx 1
    set word $argv
    set length (sizeof $word)
    while test $ndx -le $length
        echo (expr substr $word $ndx 1)
        set ndx (math "$ndx + 1" )
    end
end

function window-name
    if defined wmctrl
        set winid $argv
        set winid (ensure-hex $winid )
        set window (wmctrl -lx | grep $winid)
        set classname (echo $window | cut -d " " -f4 | cut -d "." -f2)
        set title (echo $window | cut -d "-" -f2- | cut -d " " -f2-)
        echo $classname $title
    else
        return 1
    end
end

function pidof
    if defined wmctrl
        unique (wmctrl -lxp | grep -iE ".*\.$argv | $argv\..*" | cut -d " " -f4)
    else
        return 1
    end
end

function ensure-hex
    set val $argv
    if not substr 0x $val
        echo (dectohex $val)
    else
        echo $val
    end
end

function ensure-dec
    set val $argv
    if substr 0x $val
        echo (hextodec $val)
    else
        echo $val
    end
end

function transform-with
   set $argv[2] (apply $argv[1] $argv[2])
end

function filter-with
    for i in $$argv[2]
        if eval $argv[1] $i
            set lst $lst $i
        end
    end
    set $argv[2] $lst
end

function filter-with-expr
    set expr $argv[1]
    set lst $argv[2..-1]
    for i in $lst
        if eval $expr $i
            echo $i
        end
    end
end

function fs-exists
    if test -d $argv
    else
        test -f $argv
    end
end

function existing-files
    for i in $argv
        if fs-exists $i
            echo $i
        end
    end
end

function is-an-image
    set imgtypes bmp gif jpg jpeg
    set type (get-ext $argv)
    contains $type $imgtypes
end
    

function filter-images
    set imgtypes bmp gif jpg jpeg
    filter-with-expr is-an-image $argv
end

function matches
    set com "echo $argv[1] | grep -E --regexp '^$argv[2..-1]\$'"
    eval $com > /dev/null
end

function contains-all
    set str $argv[1]
    set words $argv[2..-1]
    for i in $words
        if substr $i $str
        else
            return 1
        end
    end
end


function range
    set cnt 1
    set max $argv
    echo $cnt
    while test $cnt -ne $max
        set cnt (math "$cnt +1")
        echo $cnt
    end
end

function signal-i3blocks
    switch $argv
        case vi3
            set val 1
        case output
            set val 2
        case playing
            set val 3
        case vpn
            set val 4
        case volume
            set val 5
        case windowtitle
            set val 6
        case wallpaper
            set val 7
        case "*"
            set val $argv
    end
    pkill -RTMIN+$val i3blocks
end

function startswith
    set tst (explode $argv[1])
    set char (echo $argv[2..-1] | cut -c1)
    for i in $tst
        if match $i $char
            # echo $i
            return 0
        end
    end
    return 1
end

function car
    echo $argv | cut -c1
end

function cdr
    echo $argv | cut -c2-
end

function positive
    test $argv -gt 0
end

function negative
    test $argv -lt 0
end

function stripsign
    if startswith "- +" $argv
        cdr $argv
    else
        echo $argv
    end
end

function balias --argument alias command
    eval 'alias $alias $command'
    if expr match $command '^sudo '>/dev/null
        set command (expr substr + $command 6 (expr length $command))
    end
    complete -c $alias -xa "(
    set -l cmd (commandline -pc | sed -e 's/^ *\S\+ *//' );
    complete -C\"$command \$cmd\";
    )"
end
function set-similar-completions --argument alias command
    if expr match $command '^sudo '>/dev/null
        set command (expr substr + $command 6 (expr length $command))
    end
    complete -c $alias -xa "(
    set -l cmd (commandline -pc | sed -e 's/^ *\S\+ *//' );
    complete -C\"$command \$cmd\";
    )"
end

balias al balias

function condense_spaces
    if exists $argv
        echo $argv | sed 's/\s\+/ /g' | trim
    else
        while read -l line
            condense_spaces $line
        end
    end
end

function subtract-from
    filter-with "not substr $argv[1]" $argv[2]
end
function sumof
    set acc 0
    for i in $argv
        set acc (math "$acc + $i")
    end
    echo $acc
end

function quote
    if exists $argv
        if not startswith \" $argv
            set val \"$argv
        end
        if not endswith \" $argv
            set val $val\"
        end
        echo $val
    else
        while read -l line
            quote $line
        end
    end
end

function singlequote
    if exists $argv
        if not startswith \' $argv
            set val \'$argv
        end
        if not endswith \' $argv
            set val $val\'
        end
        echo $val
    else
        while read -l line
            quote $argv
        end
    end
end

function quote-list
    if exists $argv
        for i in $argv
            echo \"$i\"
        end
    else
        while read -l line
            quote $argv
        end
    end
end

function ensure_valid_index
    set num $argv[1]
    set cnt (count $argv[2..-1])
    if test $num -eq $cnt
        echo 1
    else
        echo (math $num + 1)
    end
end

function notreal
    dasfadf
end

# function match-lists-v
#     set ndx (findindex $argv[3] $$argv[1])
#     echo $$argv[2][$ndx]
# end

# function match-lists
#     set val $argv[1]
#     set l1 $argv[2..-2]
#     set l2 (explode $argv[-1])
#     set ndx (findindex $val $l1)
#     if exists $ndx
#         echo $l2[$ndx]
#     else
#         echo (endof $l2)
#     end
# end
function match-lists
    set val $argv[1]
    set l1 (explode $argv[2])
    set l2 (explode $argv[3])
    set default $argv[4]
    set ndx1 (findindex $val $l1)
    set ndx2 (findindex $val $l2)
    if exists $ndx1
        echo $l2[$ndx1]
    else if exists $ndx2
        echo $l1[$ndx2]
    else
        echo $default
    end
end

function endof
    echo $argv[-1]
end

function delete-blank-lines
    echo $argv | sed '/^\s*$/d'
end

function increase
    echo (math $argv +1)
end

function startof
    echo $argv[1]
end

function squish
    if exists $argv
        echo $argv | sed "s/ //g"
    else
        while read -l line
            echo (squish $line)
        end
    end
end

function stripquotes
    echo $argv | sed 's/"//g'
end

function ternary
    if eval $argv[1]
        eval $argv[2]
    else
        eval $argv[2]
    end
end

function many
    test $argv -gt 1
end

function add-unique-to-list
    if not contains $argv[1] $argv[2..-1]
        println $argv
    else
        println $argv[2..-1]
    end
end

function remove-from-list
    set target $argv[1]
    set lst $argv[2..-1]
    for i in $lst
        if not match $i $target
            echo $i
        end
    end
end

function istrue
    if contains $argv t true 1
    end
end

function isfalse
    if contains $argv f false 0
    end
end

function toggle-bool
    match-lists $argv "0 f F false False" "1 t T true True" error
end

function apply-to-list
    set fn $argv[1]
    set lst $argv[2..-1]
    for i in $lst
        eval $fn $i
    end
end

#colors
set red    '\e[0;31m'
set blue   '\e[0;34m'
set green  '\e[0;32m'
set cyan   '\e[0;36m'
set purple '\e[0;35m'
set nc     '\e[0m'
set white  '\e[0;37m'

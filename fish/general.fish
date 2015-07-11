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
        test (sizeof $argv[1]) -gt 0
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

function findall2
    if [ $argv[1] = -p ]
        set target $argv[2]
        set types $argv[3..-1]
    else
        set target (pwd)
        set types $argv
    end
    
    set pth (pwd)
    cd $target
    set start 'find ./ -regextype posix-extended -regex ".*\.('
    set ending ')"'
    set pipe '|'
    for i in $types
        set middle $i $pipe $middle
    end
    set middle (condense $middle)
    set middle (echo $middle | rev | cut -d '|' -f2- | rev)
    set results (eval (condense $start $middle $ending))
    cd $pth
    println $results

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

function waituntilfocused
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

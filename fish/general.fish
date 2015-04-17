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
        echo $i
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
    echo $argv[2..-1] | rev | cut -d $argv[1] -f1 | rev
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
    set start 'find ./ -regextype posix-extended -regex ".*\.('
    set ending ')"'
    set pipe '|'
    for i in $argv
        set middle $i $pipe $middle
    end
    set middle (condense $middle)
    set middle (echo $middle | rev | cut -d '|' -f2- | rev)
    eval (condense $start $middle $ending)

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

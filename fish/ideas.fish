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
function match
    set str1 (tolower $argv[1])
    set str2 (tolower $argv[2])
    if [ $str1 = $str2 ]
        return 0
    else
        return 1
    end
end

function has
    set target $argv[1]
    for i in $$argv[2]
        echo $i
        set acc $acc (tolower $i)
    end
    println $acc
end

function tolower
    echo $argv | tr '[:upper:]' '[:lower:]' 
end


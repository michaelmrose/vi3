function get-ws-info
    switch (count $argv)
        case 3
            set desired $argv[1]
            set var $argv[2]
            set val $argv[3]
        case 6
            set desired $argv[2]
            set var $argv[4]
            set val $argv[6] 
        end

    if contains $desired x y width height
        set desired rect.$desired
    end
    i3-msg -t get_workspaces|jq .[]|jq -r "select(.$var == $val).$desired"
end

al wsi get-ws-info

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
    get-ws-info get output where visible = true
end

function autoswitchdisplays
    switch (count (get-connected-displays))
        case 1
            switchconfig dual
        case 2
            switchconfig single
    end
end

function sigtest
    killall -SIGSTOP i3
    sleep 3
    killall -SIGCONT i3
end


function switchconfig
    set primary DVI-I-0
    set secondary DVI-I-1
    switch $argv
        case "single"
            xrandr --output $primary --auto --output $secondary --off
        case "other"
            xrandr --output $secondary --auto --output $primary --off
        case "dual"
            xrandr --output $primary --auto --output $secondary --auto --left-of $primary
    end
end

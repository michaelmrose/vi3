#vi3.fish provides helper functions to provide vi like keybindings for the i3 window manager

function defop
    set -U operation $argv[1]_op
    set -U numberofkeys $argv[2]
    set -U finalfunction $argv[3..-1]
    functions -e $argv[1]_op
    functions -e $argv[1]

    function $argv[1]_op
        eval $finalfunction
    end

    function $argv[1]
         eval vi3_take-{$numberofkeys} $argv[1] $operation
    end
end

function vi3_start-vi3
    vi3_define-vars
    vi3_setup-keyboard
    vi3_bind-shift-keys
end

function vi3_define-vars
    set -U vi3_targetMode default # valid values default and command
    set -U vi3_currentDesktop 1
    set -U vi3_lastDesktop 1
    set -U vi3_workspaceOperation # valid values lws sws saw law
    set -U vi3_currentmode default
end

function vi3_setup-keyboard
    /opt/bin/xcape -e 'Super_L=XF86LaunchB'
    /opt/bin/xcape -e 'Alt_L=Page_Up'
    /opt/bin/xcape -e 'Control_L=Page_Down'
    /opt/bin/xcape -e 'Alt_R=XF86Launch3'
    /opt/bin/xcape -e 'Super_R=XF86Launch4'
    /opt/bin/xcape -e 'Menu=XF86Launch5'
    /opt/bin/xcape -e 'Control_R=XF86Launch6'
end

function vi3_bind-shift-keys
    /opt/bin/xcape -e 'Shift_L=XF86Launch1'
    /opt/bin/xcape -e 'Shift_R=XF86Launch2'
end

function vi3_kill-shift-keys
    killall xcape
    vi3_setup-keyboard
end

function toggle-shift-keys
    if [ $shiftkeys = enabled ]
        set shiftkeys disabled
        msg shift keys disabled
        killall xcape
        vi3_setup-keyboard
    else
        set shiftkeys enabled
        msg shift keys enabled
        /opt/bin/xcape -e 'Shift_L=XF86Launch1'
        /opt/bin/xcape -e 'Shift_R=XF86Launch2'
    end
end

function vi3_combo
    vi3_get-workspace $combolist[1]
    vi3_get-workspace $combolist[2]
    er vi3op
    update-op-status
end

function vi3_rearrange
    save-workspaces
    vi3_workspace $combolist[1]
    vi3_take-window-to-workspace $combolist[2]
    restore-workspaces
    er vi3op
    update-op-status
end

function vi3_change-all
    set num 1
    for i in $combolist
        vi3_workspace $combolist[$num]
        set num (math $num + 1)
    end
    er vi3op
    update-op-status
end

function vi3_change-all-workspaces
    set numdisplays (get-number-of-displays)
    eval vi3_take-{$numdisplays} $argv[1] vi3_change-all
    er vi3op
    update-op-status
end

function get-active-workspaces
    for i in (get-connected-displays) 
        echo (getCurrentWorkspace)
        im focus output right
    end
end

function focus-primary
    im focus output (get-primary-display) 
end

function restore-workspaces
    for i in $workspaces
        im workspace $i
    end
end

function save-workspaces
    set -U workspaces (get-active-workspaces)
end

function evalandrestore
   # set -U workspaces (get-active-workspaces)
    save-workspaces
    eval $argv
    restore-workspaces
end

function vi3_kill
    im kill
end

function vi3_take-n

# takes a letter which is added to a list a function to eval
# and a number n when the list is n letters long the function 
# is evaluated making use of the list

    set -U combolist $combolist $argv[1]
    if test (count $combolist) = $argv[3]
        eval $argv[2]
        echo "done!"
        set -e combolist
        im mode "default"
    else
        echo "not yet"
        im mode "op"
    end
    er vi3op
    update-op-status
end

function vi3_take-1
    vi3_take-n $argv[1] $argv[2] 1
end

function vi3_take-2
    vi3_take-n $argv[1] $argv[2] 2
end


function vi3_combine-workspaces
    evalandrestore vi3_take-2 $argv[1] vi3_combo
    er vi3op
    update-op-status
end

function vi3_rearrange-workspaces
    evalandrestore vi3_take-2 $argv[1] vi3_rearrange
    er vi3op
    update-op-status
end

function vi3_trans-set
    trans .{$combolist[1]}{$combolist[2]}
    er vi3op
    update-op-status
end

function vi3_trans
    vi3_take-2 $argv[1] vi3_trans-set
end

function vi3_vol-set
    setvol {$combolist[1]}{$combolist[2]}
    er vi3op
    update-op-status
end

function vi3_vol
    vi3_take-2 $argv[1] vi3_vol-set
end

function vi3_width-set
    set-window-size perc width {$combolist[1]}{$combolist[2]}
    er vi3op
    update-op-status
end

function vi3_width
    vi3_take-2 $argv[1] vi3_width-set
end

function vi3_height-set
    set-window-size perc height {$combolist[1]}{$combolist[2]}
    er vi3op
    update-op-status
end

function vi3_height
    vi3_take-2 $argv[1] vi3_height-set
end

function vi3_workspace
    im workspace $argv
    er vi3op
    update-op-status
end

function vi3_op_workspace2
    vi3_take-1 $argv[1] vi3_workspace2
end

function vi3_workspace2
    im workspace $combolist[1]
end

function vi3_take-window-to-workspace
    im move container to workspace $argv
    vi3_workspace $argv
    er vi3op
    update-op-status
end

function vi3_move-window-to-workspace
    im move container to workspace $argv
    er vi3op
    update-op-status
end

function vi3_operator-mode
    setme vi3op $argv  
    pkill -RTMIN+1 i3blocks
    update-op-status
    im mode "op"
end

function vi3_fetch-window
    focus-app $argv
    vi3_take-back
    er vi3op
    update-op-status
end

function vi3_take-back
    im move container to workspace back_and_forth
    im workspace back_and_forth
end

function vi3_backout
    set -e vi3op
    set -e combolist
    set -U numkeyed 0
    im mode "default"
    update-op-status
end

function update-op-status
    pkill -RTMIN+1 i3blocks
end

function vi3_get-workspace
    checkpoint-ws
    vi3_workspace $argv 
    vi3_select-all-in-workspace
    vi3_take-back
    restore-ws
    er vi3op
    update-op-status
end

function checkpoint-ws
    set -U current_ws (get-active-workspaces)
end

function restore-ws
    for i in $current_ws;im workspace $i;end
end

function vi3_select-all-in-workspace
    im focus parent
    im focus parent
    im focus parent
    im focus parent
    im focus parent
end

function append-and-eval
   set result $argv[1] $argv[2]
   eval $result
end

function evalvi3op
    append-and-eval $vi3op $argv
end

function focus-app
    set currentclass (winclass)
    set target (app-switch $argv)
    if match $currentclass $target
        nextwindow
        msg next
    else
        set -U lasttarget $target
        focus $target
    end
    er vi3op
    update-op-status
end

function kill-app
    save-workspaces
    focus-app $argv
    sleep 0.5
    im kill
    restore-workspaces
    er vi3op
    update-op-status
end

function kill-all-app
    set target (app-switch $argv)
    killall (tolower $target)
    er vi3op
    update-op-status
end

function focus-next
    nextmatch $lasttarget
end

function open-app
    set target (app-switch $argv)
    eval $target
    er vi3op
    update-op-status
end

function select-all-in-workspace
    im focus parent
    im focus parent
    im focus parent
end

function kill-workspace
    select-all-in-workspace
    im kill
end

function kill-other-windows
    im move container to workspace keep
    kill-workspace
    vi3_get-workspace keep
end
    

function destroy-everything
    set displays (get-connected-displays)
    for i in $displays
        im focus output right
        kill-workspace
    end
end

function update-vi3-config
    rm ~/.i3/config
    cat /opt/vi3/header.txt ~/.i3/colors/{$colors} ~/.i3/personalconfig /opt/vi3/vi3config > ~/.i3/config
    im restart
end

function colorscheme
    set -U colors $argv
    update-vi3-config
end

function saveme
    i3-save-tree --workspace (getCurrentWorkspace) | sed 's-^\([[:blank:]]*\)//\([[:blank:]]"class".*\),$-\1\2-' > ~/.i3/sessions/{$argv}.json
    set sessionscript ~/sessions/{$argv}
    echo '#!/usr/bin/fish' > $sessionscript
    chmod +x $sessionscript
    eval $EDITOR $sessionscript
end

function restoreme
    im append_layout ~/.i3/sessions/{$argv}.json
    ff ~/sessions/{$argv}
end

function vi3_firstrun
    cat ~/.config/fish/config.fish /opt/vi3/fishconfig.txt > /tmp/tmpvi3fish
    cp /tmp/tmpvi3fish ~/.config/fish/config.fish
    cp /opt/vi3/personalconfigexample ~/.i3/personalconfig
    cp /opt/vi3/template.json ~/.i3/sessions/template.json
    mkdir ~/sessions
    mkdir ~/.i3/sessions
    mkdir ~/.i3/colors
    set -U colors greenandyellow
    update-vi3-config
end

function makescript
    set f $argv
    touch $f
    echo '#!/usr/bin/fish' > $f
    chmod +x $f
end

function new-open-app
    set target (app-switch $argv)
    set winclass (capitalize $target)
    set sizeof (math $numkeyed \* 2)

    if [ $numkeyed = "0" ]
        echo "no size chosen"
    else
        cat ~/.i3/sessions/template.json | sed "s/#size/$sizeof/g" | sed "s/#winclass/$winclass/g" > /tmp/template.json
        im append_layout /tmp/template.json
        set -U numkeyed 0
    end

    eval $target
end

function set-size-of-next-window
    set -U numkeyed $argv
end

function defaultmode
    im mode "default"
    set -U numkeyed 0
end

function im
    eval i3-msg $argv > /dev/null
end

function get-focused-workspace
    set list (get-active-workspaces)
    echo $list[1]
end

function show-op
    if exists $vi3op
        switch $vi3op
            case "ws"
                set msg "switch workspace [a-z]"
            case "vi3_trans"
                set msg "set transparency [0-99]"
            case "gws"
                set msg "get windows from [a-z]"
            case "mws"
                set msg "move window to [a-z]"
            case "tws"
                set msg "take window to [a-z]"
            case "vi3_vol"
                set msg "set volume [0-99]"
            case "focus-app"
                set msg "focus appkey [a-zA-Z]"
            case "vi3_fetch-window"
                set msg "fetch appkey[a-zA-Z]"
            case "new-open-app"
                set msg "open appkey [a-zA-Z]"
            case "rws"
                set msg "relocate windows from [a-z] to [a-z]"
            case "kill-all-app"
                set msg "kill all instances of appkey [a-zA-Z]"
            case "*"
                set msg "some other op"
        end
    
        echo $msg
    else
        echo none
    end
    
end

function show-appkeys
    for i in $alphabet
        set var app_key_$i
        echo result $i: $$var
    end
end

function app-switch
    set var appkey_$argv
    echo $$var
end

function appkey
    switch (count $argv)
        case "1"
        app-switch $argv
        case "2"
            set value appkey_$argv[1]
            set -U $value $argv[2]
    end
end

function erase_appkey
    er appkey_$argv
end

alias ws vi3_workspace
alias gws vi3_get-workspace
alias cws vi3_combine-workspaces
alias rws vi3_rearrange-workspaces
alias saw vi3_select-all-in-workspace
alias mws vi3_move-window-to-workspace
alias tws vi3_take-window-to-workspace

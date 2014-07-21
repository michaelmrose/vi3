#vi3.fish provides helper functions to provide vi like keybindings for the i3 window manager
. /opt/vi3/fish/utilities.fish

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
    /opt/bin/xcape -e 'Shift_L=XF86Launch1'
    /opt/bin/xcape -e 'Shift_R=XF86Launch2'

end

function vi3_kill-shift-keys
    killall xcape
    /opt/bin/xcape -e 'Control_L=Page_Down'
    /opt/bin/xcape -e 'Super_L=XF86LaunchB'
    /opt/bin/xcape -e 'Alt_L=Page_Up'
    /opt/bin/xcape -e 'Shift_R=XF86Launch2'
end

function vi3_restore-shift-keys
    /opt/bin/xcape -e 'Shift_L=XF86Launch1'
    /opt/bin/xcape -e 'Shift_R=XF86Launch2'
    /opt/bin/xcape -e 'Control_L=Page_Down'
    /opt/bin/xcape -e 'Alt_L=Page_Up'
end


function vi3_combo
    vi3_get-workspace $combolist[1]
    vi3_get-workspace $combolist[2]
end

function vi3_rearrange
    vi3_workspace $combolist[1]
    vi3_take-window-to-workspace $combolist[2]
end

function vi3_change-all
    set num 1
    for i in $combolist
        vi3_workspace $combolist[$num]
        set num (math $num + 1)
    end
end

function vi3_change-all-workspaces
    set numdisplays (get-number-of-displays)
    eval vi3_take-{$numdisplays} $argv[1] vi3_change-all
end

function get-active-workspaces
    set -e workspaces
    for i in (get-connected-displays) 
        set -U workspaces $workspaces (getCurrentWorkspace)
        i3-msg focus output right
    end
    echo (count $workspaces)
    echo $workspaces
end
   

function focus-primary
    i3-msg focus output (get-primary-display) 
end

function restore-workspaces
    # vi3_workspace $workspaceleft 
    # vi3_workspace $workspaceright
    for i in $workspaces
        i3-msg workspace $i
    end
end

function evalandrestore
    get-active-workspaces
    eval $argv
    restore-workspaces
end

function vi3_kill
    i3-msg kill
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
        i3-msg mode "default"
    else
        echo "not yet"
        i3-msg mode "op"
    end
end

function vi3_take-2
    vi3_take-n $argv[1] $argv[2] 2
end


function vi3_combine-workspaces
    evalandrestore vi3_take-2 $argv[1] vi3_combo
end

function vi3_rearrange-workspaces
    evalandrestore vi3_take-2 $argv[1] vi3_rearrange
end

function vi3_trans-set
    trans .{$combolist[1]}{$combolist[2]}
end

function vi3_trans
    vi3_take-2 $argv[1] vi3_trans-set
end

# defop vi3_trans-set 2 'trans .{$combolist[1]}{$combolist[2]}'

function vi3_vol-set
    setvol {$combolist[1]}{$combolist[2]}
end

function vi3_vol
    vi3_take-2 $argv[1] vi3_vol-set
end

# defop vi3_vol 2 'setvol {$combolist[1]}{$combolist[2]}'

function vi3_workspace
    i3-msg workspace $argv
end

function vi3_take-window-to-workspace
    i3-msg move container to workspace $argv
    vi3_workspace $argv
end

function vi3_move-window-to-workspace
    i3-msg move container to workspace $argv
end

function vi3_operator-mode
    setme vi3op $argv  
    i3-msg mode "op"
end

function vi3_fetch-window
    focus-app $argv
    vi3_take-back
end

function vi3_take-back
    i3-msg move container to workspace back_and_forth
    i3-msg workspace back_and_forth
end

function vi3_backout
    set -e vi3op
    set -e combolist
    set -U numkeyed 0
    i3-msg mode "default"
end

function vi3_get-workspace
    vi3_workspace $argv 
    vi3_select-all-in-workspace
    vi3_take-back
end

function vi3_select-all-in-workspace
    i3-msg focus parent
    i3-msg focus parent
    i3-msg focus parent
    i3-msg focus parent
    i3-msg focus parent
end

function append-and-eval
   set result $argv[1] $argv[2]
   eval $result
end

function evalvi3op
    append-and-eval $vi3op $argv
end

function app-switch
    switch $argv
        case "b"
            set returnval "firefox"
        case "c"
            set returnval "speedcrunch"
        case "d"
            set returnval "qbittorrent"
        case "e"
            set returnval "nvpy"
        case "f"
            set returnval "dolphin"
        case "g"
            set returnval "gcalendar"
        case "h"
            set returnval "hexchat"
        case "i"
            set returnval "idea"
        case "j"
            set returnval "nil"
        case "k"
            set returnval "kmix"
        case "l"
            set returnval "calibre"
        case "m"
            set returnval "clementine"
        case "M"
            set returnval "vlc"
        case "n"
            set returnval "ff noteit"
        case "o"
            set returnval "systemsettings"
        case "O"
            set returnval "kdesudo systemsettings"
        case "p"
            set returnval "kdesudo synaptic "
        case "q"
            set returnval "nil"
        case "r"
            set returnval "nil"
        case "s"
            set returnval "nil"
        case "t"
            set returnval "konsole"
        case "u"
            set returnval "nil"
        case "v"
            set returnval "qvim"
        case "w"
            set returnval "libreoffice"
        case "x"
            set returnval "ksnapshot"
        case "y"
            set returnval "nil"
        case "z"
            set returnval "zathura"
        case "*"
            set returnval "msg invalid selection"
        end
    echo $returnval
end

function focus-app
    set target (app-switch $argv)
    set -U lasttarget $target
    focus $target
end

function focus-next
    nextmatch $lasttarget
end

function open-app
    set target (app-switch $argv)
    eval $target
end

function select-all-in-workspace
    i3-msg focus parent
    i3-msg focus parent
    i3-msg focus parent
end

function kill-workspace
    select-all-in-workspace
    i3-msg kill
end

function destroy-everything
    set displays (get-connected-displays)
    for i in $displays
        i3-msg focus output right
        kill-workspace
    end
end

function update-vi3-config
    rm ~/.i3/config
    cat /opt/vi3/header.txt ~/.i3/colors/{$colors} ~/.i3/personalconfig /opt/vi3/vi3config > ~/.i3/config
    i3-msg restart
end

function colorscheme
    set -U colors $argv
    update-vi3-config
end

function saveme
    i3-save-tree --workspace (getCurrentWorkspace) | sed 's-^\([[:blank:]]*\)//\([[:blank:]]"class".*\),$-\1\2-' > ~/.i3/sessions/{$argv}.json
    echo '#!/usr/bin/fish' > ~/sessions/{$argv}
    chmod +x ~/sessions/{$argv}
    session-edit $argv
    # set sessionname ~/sessions/{$argv}
    # makescript $sessionname
    # eval $EDITOR $sessionname
end

function restoreme
    i3-msg append_layout ~/.i3/sessions/{$argv}.json
    ff ~/sessions/{$argv}
end

function vi3_firstrun
   touch ~/.config/fish.fish
   touch ~/.i3/config
   cat ~/.config/fish/config.fish /opt/vi3/fishconfig.txt > ~/tmpvi3fish
   cp ~/tmpvi3fish ~/.config/fish/config.fish
   cp /opt/vi3/personalconfigexample ~/.i3/personalconfig
   update-vi3-config
end

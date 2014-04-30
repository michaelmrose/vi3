#vi3.fish provides helper functions to provide vi like keybindings for the i3 window manager
. /opt/vi3/fish/utilities.fish

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
end


function vi3_combo
    vi3_get-workspace $combolist[1]
    vi3_get-workspace $combolist[2]
end

function vi3_rearrange
    set -l myworkspace (getCurrentWorkspace) 
    vi3_workspace $combolist[1]
    vi3_take-window-to-workspace $combolist[2]
    vi3_workspace $myworkspace 
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

function vi3_take-two
    vi3_take-n $argv[1] $argv[2] 2
end


function vi3_combine-workspaces
    vi3_take-two $argv[1] vi3_combo
end

function vi3_rearrange-workspaces
    vi3_take-two $argv[1] vi3_rearrange
end

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

function vi3_backout
    set -e vi3op
    set -e combolist
    i3-msg mode "default"
end

function vi3_get-workspace
    vi3_workspace $argv 
    echo "moving to " $argv
    vi3_select-all-in-workspace
    echo "focusing parent"
    i3-msg move container to workspace back_and_forth
    i3-msg workspace back_and_forth
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
            set returnval "kcalc"
        case "d"
            set returnval "qbittorrent"
        case "e"
            set returnval "nvpy"
        case "f"
            set returnval "dolphin"
        case "g"
            set returnval "steam"
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
            set returnval "lxterminal"
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
            set returnval "nil"
        case "*"
            set returnval "msg invalid selection"
        end
    echo $returnval
end

function focus-app
    set target (app-switch $argv)
    focus $target
end

function open-app
    set target (app-switch $argv)
    eval $target
end

function open-to-workspace
    eval $argv[1]
    sleep $argv[2]
    focus $argv[1]
    vi3_move-window-to-workspace $argv[3]
end

function update-config
    rm ~/.i3/config
    cat /opt/vi3/header.txt ~/.i3/personalconfig /opt/vi3/vi3config > ~/.i3/config
    i3-msg restart
end

function vi3_firstrun
   cat ~/.config/fish/config.fish /opt/vi3/fishconfig.txt > /tmp/vi3fish
   cp /tmp/vi3fish ~/.config/fish/config.fish
   cp /opt/vi3/personalconfigexample ~/.i3/personalconfig
   update-config
end

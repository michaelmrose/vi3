function lockme
    save-workspaces
    i3-msg mode locked
    for i in (get-connected-displays)
        i3-msg focus output $i
        i3-msg workspace {$i}_is_locked
    end
    i3-msg bar mode invisible
end

function unlockme
    i3-msg mode default
    i3-msg bar mode dock
    restore-workspaces
end

# function save-workspaces
#     set -U workspaces (get-active-workspaces)
# end

# function restore-workspaces
#     for i in (reverse $workspaces)
#         i3-msg workspace $i
#     end
# end

# function reverse
#     set size (count $argv)
#     println $argv[$size..1]
# end

# function println
#     for i in $argv
#         echo -e $i
#     end
# end

# function get-active-workspaces
#     for i in (get-connected-displays)
#         echo (getCurrentWorkspace)
#         i3-msg focus output right
#     end
# end

# function get-connected-displays
#     xrandr | grep " connected" | cut -d "c" -f1 | trim
# end

# function pi3
#    echo "import i3"\n{$argv} | python
# end 

# function getCurrentWorkspace
#     pi3 "print i3.filter(i3.get_workspaces(), focused=True)[0]['name']"
# end

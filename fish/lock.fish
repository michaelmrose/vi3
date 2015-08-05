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

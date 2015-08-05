#!/usr/bin/env fish

function floatingterm
    lxterminal &
    waituntilfocused Lxterminal
    i3-msg floating enable
end

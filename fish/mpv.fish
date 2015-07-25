function mpv-open
    #open mpv with a socket at /tmp/mpv-pid
end

function mpv-send
    #send a json message to either an instance specified or the one corresponding to the focused one
end

function mpv-get
    #get a value via mpv-send
end

function mpv-set
    #set a value via mpv-send
end

function mpv-edit-playlist
    #edit playlist of current instance of mpv in vim
end

function mpv-set-playlist
    #set current mpv to the playlist in /tmp/mpv-pid-playlist
end

function mpv-validate-playlist
    #ensure each line is a file if not find a file in $videoshome that is nearest and replace entry with that
    #enables you to write movie name in playlist instead of /full/path/andexactspellinganadcapitization
end

function mpv-validate-playlist-entry
end

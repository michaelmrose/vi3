function mimet
    switch $argv
        case http
            echo "x-scheme-hander/http"
        case https
            echo "x-scheme-hander/https"
        case directory
            echo "inode/directory"
        case "*"
            mimetype file.{$argv} | cut -d ":" -f2- | trim
    end
end

function mime-set
    set ext $argv[1]
    set mimetype (mimet file.$ext)
    set command $argv[2]

    set video mkv wmv avi mov mp4
    set audio mp3 flac ogg
    
    if not desktop_file_exists $command
        create_desktop_file $command $mimetype 
    end
    
    switch $ext
        case "video"
            for i in $video
                mime-set $i $command
            end
        case "audio"
            for i in $audio
                mime-set $i $command
            end
        case "*"
            gvfs-mime --set $mimetype $command.desktop
    end
end

function mimeq
    echo (gvfs-mime --query (mimet $argv))[1] | cut -d ":" -f2 | cut -d "." -f1 | trim
end

function desktop_file_exists
    if test -f ~/.local/share/applications/{$argv}.desktop
    else if test -f /usr/share/applications/{$argv}.desktop
    end
end

function create_desktop_file
    set app $argv[1]
    set mimetype $argv[2]
    set text[1] "[Desktop Entry]"
    set text[2] "Exec=$app"
    set text[3] "MimeType=$mimetype"\;
    set text[4] "Name=$app"
    set text[5] "NoDisplay=true"
    set text[6] "Type=Application"
    
    set target ~/.local/share/applications/{$app}.desktop
    println $text > $target
end

function mime
    switch $argv[1]
        case set
            mime-set $argv[2..-1]
        case query
            mimeq $argv[2..-1]
        case type
            mimet $argv[2..-1]
    end
end

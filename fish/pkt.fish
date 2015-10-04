function list-pkt-articles
    pocketcli -f $argv --direct
end

function list-pkt-urls
    for i in (list-pkt-articles $argv)
        cutlastn : -2 $i | trim
    end
end

function list-pkt-titles
    for i in (list-pkt-articles $argv)
        cutlastn : 3- $i | cut -d '"' -f2-
    end
end

function pkt
    switch (count $argv)
        case 0
            set tag 'tech'
            set query ''
        case 1
            set tag $argv[1]
            set query ''
        case 2
            set tag $argv[1]
            set query $argv[2]
    end
    mpv (extract-pkt-url (rfi match "select from: " (list-pkt-articles $tag | grep -i $query)))
end

    # set lst (list-pkt-articles $tag | grep -i $query)
    # if exists $lst
    #     set res (rfi match "select from: " $lst)
    #     if exists $res
    #         set url (extract-pkt-url $res)
    #         if exists $url
    #             open $url
    #         else
    #             echo no url extracted
    #         end
    #     else
    #         echo no item chosen
    #         return 1
    #     end
    # end

function extract-pkt-url
    if exists $argv
        cutlastn : -2 $argv | trim
    end
end

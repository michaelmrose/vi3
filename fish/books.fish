function books
    set selector $argv[1]
    set criteria author title publisher series tag tags
    set formats pdf epub mobi djvu lit chm txt
    
    if contains $selector $criteria
        set query $argv[2..-1]
    else
        set selector title
        set query $argv
    end

    set filenames (find-books $selector $query)
    # set filenames (find-books $query)
    set books (apply extract-title filenames | sort | uniq)

    for i in $filenames
        set filetype (extract-filetype $i)
        set $filetype $filetpe $i
    end

    set nbooks (count $books)

    switch $nbooks
        case 0
            echo "Search produced no results"
        case 1
            for i in $formats
                if contains $$i $filenames
                    open $$i
                    return 0
                end
            end
            
        case "*"
            # given many results find out if one is an exact match
            for i in $books
                set val (echo $i | trim)
                if match $val $query
                    #ok so one is an exact match
                    for j in $filenames
                        set title (echo $j | extract-title)
                        # lets find the filename which contains the title 
                        # that we want and open it
                        if match $title $query
                            # add everything that matches to $matches
                            set matches $matches $j
                        end
                    end
                    #now find a each of the suitable formats see if there is a match for it in filenames
                    for i in $formats
                        if contains $$i $filenames
                            open $$i
                            return 0
                        end
                    end
                end
            end
            # so no exact match so show a menu and pipe the users choice to 
            # books where it will now be an exact match 
            fuzzymenu (println $books | sed 's/_/:/g')
            println $books
            #fuzzymenu sets global fquery variable because fzf is broken within variable sub in fish
            books $fquery
        end
end

function find-books
    set selector $argv[1]
    set query $argv[2..-1]
    set correctedquery (echo $query | sed 's/:/_/g')
    set returnval (calibredb list -s "$selector:~^.*"{$query}"" -f formats --for-machine | grep /home | cut -d '"' -f2 | grep -i "$correctedquery")
    println $returnval
 end

function extract-title
    if exists $argv
        echo $argv | cut -d "." -f1 | cut -d "/" -f7 | cut -d "(" -f1 | trim | sed 's/\\\//g'
    else
        while read -l line
            echo $line | cut -d "." -f1 | cut -d "/" -f7 | cut -d "(" -f1 | trim | sed 's/\\\/ /g'
        end
    end
end

function extract-filetype
    if exists $argv
        echo (cutlast . $argv)
    else
        while read -l line
            echo (cutlast . $line)
        end
        return 0
    end
end

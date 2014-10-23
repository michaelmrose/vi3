function books
   
    # test if we have called without args so we wont try to expand args that don't exist 
    if not exists $argv
        show-recent-reads
        return 0
    end

    # selector is going to be the first arg and if it turns out to be a valid criteria
    # like author we are going to end up assuming the rest is the query
    # otherwise the implicit criteria is title and the the whole of the remaining args
    # make up the query  

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
    set books (apply extract-title filenames | sort | uniq)
    
    # kind of non obvious but this sets the value of a variable named for each filetype to the
    # value of a file of that type useful once we have it narrowed down to one book as
    # pdf will equal the name of the pdf version epub the epub version and so on

    for i in $filenames
        set filetype (extract-filetype $i)
        set $filetype $i
    end

    set nbooks (count $books)

    switch $nbooks
        case 0
            echo "Search produced no results"
        case 1
            for i in $formats
                if contains $$i $filenames
                    # $$i will contain the value of $pdf if $i is pdf
                    # and if it exists in filenames we have found what we want to open
                    set target $$i
                    break
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
                            set target $$i
                        end
                    end
                    #now find a each of the suitable formats see if there is a match for it in filenames
                    for i in $formats
                        if contains $$i $filenames
                            set target $$i
                            break
                        end
                    end
                end
            end
        end
      
        if exists $target
            add-to-recent-reads (echo $target | extract-title)
            open $target
        else
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

function show-recent-reads
    fuzzymenu (println $recent_reads)
    books $fquery
end

function totitle
    echo $argv | sed 's/_/:/g'
end

function tofname
    echo $argv | sed 's/:/_/g'
end

function add-to-recent-reads
    set -l maxreads 20
    set -l ndx (math "$maxreads +1")
    set realtitle (totitle $argv)
    set -U recent_reads $recent_reads $realtitle
    set recent_reads (unique $recent_reads)
    if test (count $recent_reads) -gt $maxreads
        set recent_reads $recent_reads[2..$ndx]
    end
end

function get-fname-of-title
    echo (calibredb list --fields formats -s "title:=$argv" --for-machine | grep '"/' | cut -d '"' -f2)
end

function unique
    for i in $argv
        if not contains $acc $i
            set acc $acc $i
        end
    end
    println $acc
end

function books
    if exists $argv
        sopen (choose-format (get-fname-of-book (add-to-recent-reads (select-book (query-calibre-title (return-query $argv))))))
        #threadback return-query query-calibre-title select-book get-fname-of-book choose-format open-book-by-title
    else
        show-recent-reads
    end
end

function query-calibre -d "usage: query-calibre [exact,contains] criteria query returns answer in json"
    set type $argv[1]
    set field $argv[2]
    set query $argv[3..-1]
    switch $type
        case "exact"
            set com (echo calibredb list --fields formats,title,$field -s {$field}:\\\"=\"$query\"\\\" --for-machine)
        case "contains"
            set com (echo calibredb list --fields formats,title,$field -s $field:$query --for-machine)
    end
    eval $com
end

function query-calibre-title -d "returns list of titles, exact if present or list containing chosen phrase"
    set result (query-calibre contains $argv | jq .[].title)
    set exact (println $result | grep -i "$argv[2..-1]")
    if exists $exact
        println $exact
    else
        println $result
    end
end

# if you hit escape when narrowing a search 
# this will be called with title "" and result 
# in the first book found being returned 

function query-calibre-formats -d "returns files for a given exact title"
    if test (sizeof $argv[2]) -gt 0 
        query-calibre exact $argv | jq .[].formats[]
    end
end

function return-query -d "returns a properly formated query for query-calibre-title"
    set selector $argv[1]
    set criteria author title publisher series tags
    
    if contains $selector $criteria
        set query $argv[2..-1]
    else
        set selector title
        set query $argv
    end
    println $selector $query
end

function get-fname-of-book -d "get whole filename of book given its title"
    set title (stripquotes $argv)
    set files (query-calibre-formats title $title)
    set name (stripquotes (get-fname-of-file $files[1]))
    echo $name
end

function choose-format -d "for the given list of formats in preferential order return the first that exists for the given book"
    set formats pdf epub mobi djvu lit chm txt
    set name $argv

    for i in $formats
        if test -f $name.$i
            echo $name.$i
            return 0
        end
    end
    return 1
end
        
function select-book -d "use dmenu to select a book if more than one is possible"
    if test (count $argv) -gt 1
        println $argv | dm menu "select book"
    else
        echo $argv
    end
end

function add-to-recent-reads -d "keep a list of the 10 most recent unique items opened via this script"
    set -U recent_reads (take 10 (unique (println $argv $recent_reads)))
    echo $argv
end

function show-recent-reads -d "use dmenu to pick one of the items from recent_reads and open it with sopen if it is a file or books if it is a title"
    set choice (println $recent_reads | dm menu "books")
    if exists $choice
        if test -f $choice
            sopen $choice
        else
            books $choice
        end
    else
        return 0
    end
end

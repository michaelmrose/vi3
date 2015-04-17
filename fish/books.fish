function books
    if exists $argv
        open-book-by-title (select-book (query-calibre-title (return-query $argv)))
    else
        show-recent-reads
    end
end

function query-calibre
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

function query-calibre-title
    set result (query-calibre contains $argv | jq .[].title)
    set exact (println $result | grep -i "$argv[2..-1]")
    if exists $exact
        println $exact
    else
        println $result
    end
end

function query-calibre-formats
    query-calibre exact $argv | jq .[].formats[]
end

function query-calibre-formats-by-title
    set books (query-calibre-title $argv[1] $argv[2..-1])
    for i in $books
        query-calibre-formats title (stripquotes $i)
    end
end

function return-query
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

function open-book-file
    set com open (quote $argv)
    add-to-recent-reads $argv
    eval $com
end

function open-book-by-title
    if not exists $argv
        return 1
    end
    set title (stripquotes $argv)
    set files (query-calibre-formats title $title)
    set name (stripquotes (get-fname-of-file $files[1]))
    set com open (quote (choose-format $name))
    add-to-recent-reads $title
    eval $com
end

function choose-format
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
        

function select-book
    if test (count $argv) -gt 1
        println $argv | dm menu "select book"
    else
        echo $argv
    end
end

function add-to-recent-reads
    set -U recent_reads (take 10 (unique (println $argv $recent_reads)))
end

function show-recent-reads
    set choice (println $recent_reads | dm menu "books")
    if exists $choice
        books $choice
    else
        return 0
    end
end

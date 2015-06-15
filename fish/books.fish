function books -d 'open books given either as a title or criteria query using rofi to narrow down multiple results or recent-reads if no input given'
    if exists $argv
        if test -f "$argv"
            open-book "$argv"
            return 0
        end
        if test (count $argv) -gt 1
            set tail $argv[2..-1]
        end
        switch $argv[1]
            case --add
                badd $tail
            case -a
                books --add $tail
            case --replacecover
                pdfkillcover "$tail"
                coverit "$tail"
            case -r
                books --replacecover $tail
            case --removewatermark
                remove-pdf-watermark "$tail"
            case -w
                books --removewatermark $tail
            case --cover 
                coverit "$tail"
            case -c
                books --cover $tail
            case --erase
                set -e recent_reads
            case -e
                books --erase
            case --query
                # open (choose-format (get-fname-of-book (add-to-recent-reads (select-book (query-calibre-title (return-query $tail))))))
                open (choose-format (get-fname-of-book (select-book (query-calibre-title (return-query $tail)))))
            case -q
                books --query $tail
            case "*"
                books --query $argv
        end

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

function book-exists
    set result (query-calibre exact title $argv | jq .[].title)
    positive (count $result)
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
    if match $selector author
        set selector authors
    end
    if match $selector tag
        set selector tags
    end
    set criteria authors title publisher series tags
    
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
        
function select-book -d "use rofi to select a book if more than one is possible"
    if test (count $argv) -gt 1
        set val (rfi match "select book: " $argv)
        if not exists $val
            return 1
        end
        if contains $val $argv
            echo $val
        end
    else
        echo $argv
    end
end

function add-to-recent-reads -d "keep a list of the 10 most recent unique items opened via this script"
    if exists $argv
        set title $argv
        set -U recent_reads (take 10 (unique (println "$title" $recent_reads)))
    else
        return 1
    end
end

function show-recent-reads -d "use rofi to pick one of the items from recent_reads and open it with sopen if it is a file or books if it is a title"
    set choice (rfi match "choose a book" $recent_reads)
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

function pdfextract -d "replaces pdf with range of pdf defined in args"
    pdftk A=$argv[1] cat A$argv[2]-$argv[3] output temp.pdf
    mv temp.pdf $argv[1]
end

function pdfkillcover
    pdfextract $argv[1] 2 end
end

function coverit -d "converts image file in clipboard to pdf and prepends to pdf supplied in argv"
   set url (xclip -o)
   wget $url --output-document=cover
   convert cover cover.pdf
   rm cover
   pdftk cover.pdf $argv cat output temp.pdf
   mv temp.pdf $argv
   rm cover.pdf
end

function remove-pdf-watermark -d "removes all watermarks from text of pdf"
    set file $argv
    set watermarks[1] "Licensed to michael rose <Michael@rosenetwork.net>"
    set watermarks[2] "www.it-ebooks.info"
    set watermarks[3] "https://forums.manning.com/forums/clojure-in-action-second-edition"
    set watermarks[4] "These will be cleaned up during production of the book by copyeditors and proofreaders."
    # set watermarks[5] "@Manning Publications Co. We welcome reader comments about anything in the manuscript - other than typos and other simple mistakes"
    set tmp1 /tmp/pdf1_{$file}
    set tmp2 /tmp/pdf2_{$file}
    echo w is $watermarks
    # set file $argv[1]
    echo f is $file
    echo t is $tmp1 $tmp2
    pdftk $file output $tmp1 uncompress
    for i in $watermarks
        set wm (echo $i | sed 's%\/%\\\/%g')
        set replace "cat $tmp1 | sed -e \"s/$wm//g\" > $tmp2"
        eval $replace
        cp $tmp2 $tmp1
    end
    pdftk $tmp1 output $file compress
    rm $tmp1
    rm $tmp2
end

function badd -d "add one or more books wherein the book consists of a file or an archive containing one or more formats of the same book"
    for i in $argv
        set tmp /tmp/thebook
        mkdir $tmp
        set archives rar

        if contains (get-ext $i) $archives
            atool -X $tmp $i
            rm $tmp/*.txt
        else
            mv $i $tmp/
        end
        calibredb add -1 $tmp
        rm -rf $tmp
        rm $i
    end
end

function sopen
    if exists $argv
        if test -f $argv
            gvfs-open (quote $argv)
        end
    else
        return 1
    end
end

function open-book
    set fullpath (pwd)/$argv
    set ext (cutlast "." $argv)
    set library $HOME/calibre
    if substr $fullpath $library #if path is in $library
        set title (query-calibre-title title (escape-chars (extract-title $fullpath)))
        add-to-recent-reads "$title"
    end
    
    switch $ext
        case "pdf"
            zathura "$argv"
        case "*"
            ebook-viewer "$argv"
    end
end

function extract-title
    cutlast "/" "$argv" | cut -d "-" -f1 | trim | sed 's/_/:/g'
end

function escape-chars
    echo "$argv" | sed "s/'/\\\'/g"
end

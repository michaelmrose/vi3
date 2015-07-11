function pkg
    switch $argv[1]
        case i
            sudo emerge $argv[2..-1]
        case r
            sudo emerge -C $argv[2..-1]
            shutitdown
        case s
            emerge --search $argv[2..-1]
        case S
            sudo emerge --sync
        case uw
            sudo emerge --sync
            sudo emerge -auDN @world
            shutitdown
        case u
            equery uses $argv[2..-1]
    end
end

function es
    switch $argv[1]
          case py
              switch $argv[2]
                  case 2
                      set vers 1
                  case 3
                      set vers 2
              end
              set com python set $vers
          case "*"
              set com $argv
    end
    sudo eselect $com
end

function serv
    switch $argv[1]
        case status
            sudo /etc/init.d/$argv[2] status
        case start
            sudo /etc/init.d/$argv[2] start
        case stop
            sudo /etc/init.d/$argv[2] stop
        case show
            rc-update show
        case add
            sudo rc-update add $argv[2] $argv[3]
        case delete
            sudo rc-update delete $argv[2] $argv[3]
    end
end

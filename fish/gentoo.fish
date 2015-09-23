function pkg
    switch $argv[1]
        case i
            sudo emerge $argv[2..-1]
            shutitdown
        case p
            emerge $argv[2..-1] --pretend
        case r
            sudo emerge -C $argv[2..-1]
            shutitdown
        case pick 
            pick-package $argv[2..-1]
        case s
            emerge --search $argv[2..-1]
        case S
            sudo emerge --sync
        case uw
            pkg updateworld
        case updateworld
            sudo emerge --sync
            sudo emerge -auDN @world --ask
            shutitdown
        case depends
            equery depends $argv[2..-1]
        case depgraph
            equery depgraph $argv[2..-1]
        case bt
            pkg buildtime $argv[2..-1]
        case buildtime
            sudo genlop -tq $argv[2..-1]
        case u
            pkg uses $argv[2..-1]
        case version
            pick-version $argv[2..-1]
        case versions
            equery y $argv[2..-1]
        case uses
            equery uses $argv[2..-1]
        case lo
            pkg listoverlay $argv[2..-1]
        case listoverlay
            eix --in-overlay $argv[2..-1]
        case addoverlay
            addoverlay $argv[2..-1]
        case installed
            eix-installed -a | grep -i $argv[2..-1]
    end
end

function pyversion
    eselect python list | grep \* | condense_spaces | cut -c11
end

function addoverlay
    sudo layman -a $argv
    sudo layman -s $argv
    sudo emerge --sync
    sudo eix-sync
end

function pip2
    pipv 2 $argv
end
function pip2
    pipv 3 $argv
end

function pipv
    set pyversion (pyversion)
    es py $argv[1]
    sudo pip $argv[2..-1]
    es py $pyversion
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
        case show
            if test (count $argv) -gt 1
                rc-update show $argv[2..-1]
            else
                rc-update show
            end
            echo
            echo -e {$white}autostarting: {$green}$restartable_services
            return 0
        case autorestart
            toggle-restartables
            return 0

    end
    switch $argv[2]
        case status
            sudo /etc/init.d/$argv[1] status
        case scriptstatus
            serv $argv[1] status | condense_spaces | cut -d " " -f3
        case start
            sudo /etc/init.d/$argv[1] start
        case stop
            sudo /etc/init.d/$argv[1] stop
        case add
            sudo rc-update add $argv[2] $argv[3]
        case delete
            sudo rc-update delete $argv[2] $argv[3]
        case restart
            toggle-restartable $argv[1]
    end
end

function pick-version
    pkg i ={$argv}-(rfi match "select a version of $argv" (equery y $argv | condense_spaces | cut -d " " -f1 | sed 's/\[I\]//g' | grep -E '[0-9]'))
end

function pick-package
    set pkg (rfi match "select a package: " (list-packages-not-installed $argv))
    pkg -i (echo $pkg | cut -d " " -f1)
end

function list-packages-not-installed
    set pkgs (list-package-names-not-installed $argv)
    set desc (list-descriptions-not-installed $argv)
    for i in (seq (count $pkgs))
        echo -e $pkgs[$i] $desc[$i]
    end
end

function list-package-names-not-installed
    pkg s $argv | grep -B2 "Not Installed" | cut -d " " -f3 | sed 's#--##g' | sed '/^\s*$/d'
end

function list-descriptions-not-installed
    pkg s $argv | grep -A 3 "Not Installed" | grep Description | condense_spaces | cut -d ":" -f2 | trim
end


function toggle-autorestart
    if istrue $restart_services
        set -U restart_services false
    else
        set -U restart_services true
    end
end

function toggle-restartables
    set -U restart_services (toggle-bool $restart_services)
    echo $restart_services
end

function maintain-services
    while true
        if match $restart_services true
            for serv in $restartable_services
                #echo s is $serv
                switch (processtype $serv)
                    case process
                        if not pgrep $serv > /dev/null
                            fish -c $serv &
                            echo restarted $serv at (date)
                         end
                    case service 
                        if not match (serv $serv scriptstatus) started 
                            serv $serv stop
                            serv $serv start
                            echo restarted $serv at (date)
                        end
                end
            end
        end
        sleep 30
    end
end

function add-to-restartable
    set -U restartable_services (add-unique-to-list $argv $restartable_services)
end

function toggle-restartable
    if contains $argv $restartable_services
        remove-from-restartable $argv
        echo $argv will no longer be restarted
    else
        add-to-restartable $argv
        echo $argv will now be restarted automatically
    end
end

function remove-from-restartable
    set -U restartable_services (remove-from-list $argv $restartable_services)
    return 0
end

function isaservice
    contains $argv (ls /etc/init.d)
end

function processtype
    if isaservice $argv
        echo service
    else
        echo process
    end
end

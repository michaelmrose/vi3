function pkg
    if contains $argv[1] (equery-fns) (equery-short-fns)
        equery $argv
        return 0
    end
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
        case search
            switch $argv[2]
                case desc
                    emerge --searchdesc $argv[3..-1]
                case '*'
                    emerge --search $argv[2..-1]
            end
        case s
            pkg search $argv[2..-1]
        case S
            sudo emerge --sync
        case uw
            pkg updateworld
        case status
            em-status
        case updateworld
            sudo emerge --sync
            sudo emerge -aUDN @world --with-bdeps=y --keep-going=y --ask
        case depends
            equery depends $argv[2..-1]
        case overlay
            addoverlay $argv[2..-1]
        case edit
            switch (count $argv)
                case 1
                    nv (rfi match "pick one: " (ls /etc/portage))
                case 2
                    nv /etc/portage/$argv[2..-1]
            end
        case bt
            pkg buildtime $argv[2..-1]
        case buildtime
            sudo genlop -tq $argv[2..-1]
        case version
            pick-version $argv[2..-1]
        case versions
            equery y $argv[2..-1]
        case lo
            pkg listoverlay $argv[2..-1]
        case listoverlay
            eix --in-overlay $argv[2..-1]
        case addoverlay
            addoverlay $argv[2..-1]
        case installed
            eix-installed -a | grep -i $argv[2..-1]
        case '*'
            pkg search $argv
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

# function emerge-status
#     if pgrep emerge > /dev/null
#         echo (build-eta)
#     else
#         echo none
#     end
# end

# function build-eta
#     if em-status > /dev/null
#         echo ETA: (cutlast : (em-status) | trim)
#     end
# end

# function build-info
#     set buildinfo (echo (sudo tail /var/log/emerge.log)[-1] | cut -d "(" -f2 | cut -d ")" -f1 | cut -c1-12)
#     echo $buildinfo | grep -E '[0-9]+ of [0-9]+'  
# end


function em-status
    if pgrep emerge > /dev/null
        if set res (sudo genlop -ntc 2> /dev/null)
            set output (condense_lines $res)
        end
    else
        return 1
    end
    if startswith ! $output
        return 1
    else
        echo $output
    end
end

function condense_lines
    for i in $argv
        set item (echo $i | sed 's#\n##g')
        set acc $acc $item
    end
    echo $acc | condense_spaces
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
            # echo -e {$white}autostarting: {$green}$restartable_services
            return 0
        case autorestart
            toggle-restartables
            return 0
        case list
            for i in (ls /etc/init.d/)
                describe-service $i
            end
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
            sudo rc-update add $argv[1] $argv[3]
        case delete
            sudo rc-update delete $argv[1] $argv[3]
        case restart
            toggle-restartable $argv[1]
        case show
            # serv show | grep $argv[1] | condense_spaces
            # describe-service $argv[1]
            condense-fns "serv show | grep $argv[1] | condense_spaces" := "describe-service $argv[1]" "serv $argv[1] status"
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

function sys
    switch $argv[1]
        case s
            sudo shutdown -h now
        case r
            sudo shutdown -r now
        case l
            i3-msg exit
        case g
            dm-tool switch-to-greeter
    end
end

function rebuild-kernel
    set com s genkernel all --install --zfs --no-clean --no-mountboot --gconfig $argv --callback=\"emerge spl zfs-kmod zfs g15daemon nvidia-drivers libg15 libg15render solaar\"
    echo command is $com
    countdown 10
    eval $com
end

function equery-fns
    println (equery -C --help | condense_spaces)[10..-1] | sed 's/(//g' | sed 's/)//g' | cut -d " " -f1
end

function equery-short-fns
    println (equery -C --help | condense_spaces)[10..-1] | cut -d '(' -f2 | cut -d ')' -f1
end


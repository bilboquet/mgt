_mgt_project_select () {
    local cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prj_list=$(mgt project list | cut -b3-)
    COMPREPLY=( $( compgen -W "$prj_list" -- ${cur} ) )
    return 0
}

_mgt_project () {
    local opts cur
    cur=${COMP_WORDS[COMP_CWORD]}
    opts="-h --help init list select sync"
    case "${COMP_WORDS[2]}" in
        -h|--help)
            ;;
        init)
            ;;
        list)
            ;;
        select)
            _mgt_project_select
            return 0
            ;;
        sync)
            ;;
        *)
            COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
            return 0
            ;;
    esac
}

_mgt_task_seach_filter () {
    local opts="Task-Id= Author= Assignee= Date= Estimation= Remaining= Tags= Depends= Description="
    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_task_seach () {
    ###TODO: add --category
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    if [[ "$COMP_LINE" == *" --interactive "* || "$COMP_LINE" == *" -i "* ]]; then
        opts="--filter"
    else 
        opts="--filter -i --interactive"
    fi

    case "$prev" in
        --filter)
            _mgt_task_seach_filter
            return 0
            ;;
    esac
    
    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_taskid () {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local category
    # Is a category defined
    for (( ind=0 ; $ind -le "${#COMP_WORDS[@]}" ; ++ind )); do
        if [ "${COMP_WORDS[$ind]}" == "-c" || "${COMP_WORDS[$ind]}" == "--category" ]; then
            # Let's suppose next element is the category
            category=${COMP_WORDS[$ind+1]}
            break
        fi
    done
    
    local tasks=$(mgt task search -c todo | sed -e 's@.*/\([0-9]*\):.*$@\1@')
    COMPREPLY=( $( compgen -W "$tasks" -- ${cur} ) )
    set +x
    return 0
}

_mgt_category () {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local categories=$(mgt category list | cut -d':' -f 1)
    COMPREPLY=( $( compgen -W "$categories" -- ${cur} ) )
    return 0
}

_mgt_task_depends () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-c --category -t --task -o --on"

    # filter used options
    if [[ "$COMP_LINE" == *" --category "* ||  "$COMP_LINE" == *" -c "* ]]; then
        opts="${opts/--category}"
        opts="${opts/-c}"
    fi
    if [[ "$COMP_LINE" == *" --task "* ||  "$COMP_LINE" == *" -t "* ]]; then
        opts="${opts/--task}"
        opts="${opts/-t}"
    fi

    case "$prev" in
        -o|--on|-t|--task)
            _mgt_taskid
            return 0
            ;;
        -c|--category)
            _mgt_category
            return 0
            ;;
    esac
#    read -ra arr <<< " --task -c -t"
#    for str in "${arr[@]}"; do
#        if [[ "$COMP_LINE" == *" $str "* ]]; then
#            opts="${opts/$str}"
#        fi
#    done

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_task () {
    local opts cur
    cur=${COMP_WORDS[COMP_CWORD]}
    opts="-h --help search add mv edit assign rm depends"
    case "${COMP_WORDS[2]}" in
        -h|--help)
            ;;
        search)
            _mgt_task_seach
            ;;
        add)
            ;;
        mv)
            ;;
        edit)
            ;;
        assign)
            ;;
        rm)
            ;;
        depends)
            _mgt_task_depends
            ;;
        *)
            COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
            return 0
            ;;
    esac
    
}

_mgt () {
    local cur prev opts

    COMPREPLY=()   # Array variable storing the possible completions.
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="init project task category config"

    case "${COMP_WORDS[1]}" in
        init)
            COMPREPLY=( $( compgen -W "-h --help  -n --new -r --remote --force" -- ${cur} ) )
            return 0
            ;;
        project)
            _mgt_project
            ;;
        task)
            _mgt_task
            ;;
        category)
            ;;
        config)
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
            return 0
            ;;
    esac
}

#complete -F _mgt -o filenames mgt.sh
complete -F _mgt mgt.sh
complete -F _mgt mgt
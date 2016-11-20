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
    opts="-h --help init list select sync history"
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
    local opts="Task-Id= Author= Assignee= Date= Estimation= Tags= Depends= Description="
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
    # Is a category defined?
    for (( ind=0 ; $ind <= ${#COMP_WORDS[@]} ; ++ind )); do
        local cur_arg="${COMP_WORDS[$ind]}"
        if [[ "$cur_arg" == "-c" || "$cur_arg" == "--category" ]]; then
            # Let's suppose next element is the category
            category="-c "${COMP_WORDS[$ind+1]}
            break
        fi
    done
    
    grep_filter='.'
    if [ ! -z ${cur} ]; then
        grep_filter=${cur}
    fi
    echo
    echo "Task id : description"
    mgt task search $category | grep -e "${category/-c /}/$grep_filter"
    echo "Full task id below for completion, you may need to hit <TAB> again."
    local tasks=$(find $MGT_PROJECT_PATH/${category/-c /} -type f -not -name '.*' -exec basename {} \;)
    COMPREPLY=( $( compgen -W "$tasks" -- ${cur} ) )
    return 0
}

_mgt_category () {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local categories=$(mgt category list | tail -n +3 | cut -d':' -f 1)
    COMPREPLY=( $( compgen -W "$categories" -- ${cur} ) )
    return 0
}

_mgt_user () {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local users=$(mgt user list | tail -n +3 | cut -d':' -f 1)
    COMPREPLY=( $( compgen -W "$users" -- ${cur} ) )
    return 0
    
}

_mgt_tag_helper ()  {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local users=$(mgt tag list | tail -n +3 | cut -d':' -f 1)
    COMPREPLY=( $( compgen -W "$users" -- ${cur} ) )
    return 0
}

_mgt_task_mv (){
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--to --from -t --task"

    # filter used options
    if [[ "$COMP_LINE" == *" --task "* ||  "$COMP_LINE" == *" -t "* ]]; then
        opts="${opts/--task}"
        opts="${opts/-t}"
    fi
    if [[ "$COMP_LINE" == *" --to "* ]]; then
        opts="${opts/--to}"
    fi
    if [[ "$COMP_LINE" == *" --from "* ]]; then
        opts="${opts/--from}"
    fi

    case "$prev" in
        -t|--task)
            _mgt_taskid
            return 0
            ;;
        --from|--to)
            _mgt_category
            return 0
            ;;
    esac

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_task_assign () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-c -t --task -u"

    # filter used options
    case "$COMP_LINE" in
        *" --task "*|*" -t "*)
            opts="${opts/--task}"
            opts="${opts/-t}"
            ;;&
        *" -c "*)
            opts="${opts/-c}"
            ;;&
        *" -u "*)
            opts="${opts/-u}"
            ;;&
    esac

    case "$prev" in
        -t|--task)
            _mgt_taskid
            return 0
            ;;
        -c)
            _mgt_category
            return 0
            ;;
        -u)
            _mgt_user
            return 0
    esac

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0

}

_mgt_task_estimate () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-c --category -t --task -e --estimation"

    # filter used options
    if [[ "$COMP_LINE" == *" --category "* ||  "$COMP_LINE" == *" -c "* ]]; then
        opts="${opts/--category}"
        opts="${opts/-c}"
    fi
    if [[ "$COMP_LINE" == *" --task "* ||  "$COMP_LINE" == *" -t "* ]]; then
        opts="${opts/--task}"
        opts="${opts/-t}"
    fi
    if [[ "$COMP_LINE" == *" --estimation "* ||  "$COMP_LINE" == *" -e "* ]]; then
        opts="${opts/--estimation}"
        opts="${opts/-e}"
    fi

    case "$prev" in
        -t|--task)
            _mgt_taskid
            return 0
            ;;
        -c|--category)
            _mgt_category
            return 0
            ;;
    esac

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_task_depends () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-c --category -t --task -o --on --ndep"

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
        -o|--on|-t|--task|--ndep)
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

_mgt_task_basic () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-c --category -t --task"

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
        -t|--task)
            _mgt_taskid
            return 0
            ;;
        -c|--category)
            _mgt_category
            return 0
            ;;
    esac

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_task () {
    local opts cur
    cur=${COMP_WORDS[COMP_CWORD]}
    opts="-h --help search add mv edit assign estimate rm depends view history"
    case "${COMP_WORDS[2]}" in
        -h|--help)
            ;;
        search)
            _mgt_task_seach
            ;;
        add)
            _mgt_task_basic
            ;;
        mv)
            _mgt_task_mv
            ;;
        edit)
            _mgt_task_basic
            ;;
        assign)
            _mgt_task_assign
            ;;
        estimate)
            _mgt_task_estimate
            ;;
        rm)
            _mgt_task_basic
            ;;
        depends)
            _mgt_task_depends
            ;;
        view)
            _mgt_task_basic
            ;;
        history)
            _mgt_task_basic
            ;;
        *)
            COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
            return 0
            ;;
    esac
    
}

_mgt_tag_add () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-l --label -T --tag"

    # filter used options
    if [[ "$COMP_LINE" == *" --label "* ||  "$COMP_LINE" == *" -l "* ]]; then
        opts="${opts/--label}"
        opts="${opts/-l}"
    fi
    if [[ "$COMP_LINE" == *" --tag "* ||  "$COMP_LINE" == *" -T "* ]]; then
        opts="${opts/--tag}"
        opts="${opts/-T}"
    fi

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_tag_rm () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-T --tag"

    # filter used options
    if [[ "$COMP_LINE" == *" --tag "* ||  "$COMP_LINE" == *" -T "* ]]; then
        opts="${opts/--tag}"
        opts="${opts/-T}"
    fi

    case "$prev" in
        -T|--tag)
            _mgt_tag_helper
            return 0
            ;;
    esac

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_tag () {
    local opts cur
    cur=${COMP_WORDS[COMP_CWORD]}
    opts="-h --help list add rm"
    case "${COMP_WORDS[2]}" in
        -h|--help)
            ;;
        list)
            ;;
        add)
            _mgt_tag_add
            ;;
        rm)
            _mgt_tag_rm
            ;;
        *)
            COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
            return 0
            ;;
    esac
}

_mgt_id () {
    local cur id
    cur=${COMP_WORDS[COMP_CWORD]}
    echo
    echo -n "Completion on 
    case "$1" in
        task)
            echo "$1."
            id=$(find "$MGT_PROJECT_PATH/" -type f -not -path "$MGT_PROJECT_PATH/comments/*" -not -name '.*' -exec basename {} \;)
            ;;
        comment)
            echo "$1."
            id=$(find "$MGT_PROJECT_PATH/comments" -type f -not -name '.*' -exec basename {} \;)
            ;;
        '')
            echo "all id."
            id=$(find "$MGT_PROJECT_PATH/" -type f -not -name '.*' -exec basename {} \;)
            ;;
        *)
            echo "Error: wrong argument to -o."
            id=''
            ;;
    esac
    
#    local tasks=$(find $MGT_PROJECT_PATH/${category/-c /} -type f -not -name '.*' -exec basename {} \;)
    COMPREPLY=( $( compgen -W "$id" -- ${cur} ) )
    
    
}

_mgt_comment_add () {
    local cur prev opts
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="-o --on -i --id -m --message"

    # filter used options
    case "$COMP_LINE" in
        *" --on "*|*" -o "*)
            opts="${opts/--on}"
            opts="${opts/-o}"
            ;;&
        *" --id "*|*" -i "*)
            opts="${opts/--id}"
            opts="${opts/-i}"
            ;;&
        *" --message "*|*" -m "*)
            opts="${opts/--message}"
            opts="${opts/-m}"
            ;;
    esac

    case "$prev" in
        -o|--on)
            COMPREPLY=( $( compgen -W "task comment" -- ${cur} ) )
            return 0
            ;;
        -i|--id)
            # Is a $on defined?
            for (( ind=0 ; $ind <= ${#COMP_WORDS[@]} ; ++ind )); do
                local cur_arg="${COMP_WORDS[$ind]}"
                if [[ "$cur_arg" == "-o" || "$cur_arg" == "--on" ]]; then
                    # Let's suppose next element is $on
                    on=${COMP_WORDS[$ind+1]}
                    break
                fi
            done
            _mgt_id "$on"
            return 0
            ;;
        -m|--message)
            return 0
            ;;
    esac

    COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
    return 0
}

_mgt_comment () {
    local opts cur
    cur=${COMP_WORDS[COMP_CWORD]}
    opts="-h --help add edit show"
    case "${COMP_WORDS[2]}" in
        -h|--help)
            ;;
        show)
            _mgt_comment_show
            ;;
        add)
            _mgt_comment_add
            ;;
        edit)
            _mgt_comment_edit
            ;;
        *)
            COMPREPLY=( $( compgen -W "${opts}" -- ${cur} ) )
            return 0
            ;;
    esac
}

_mgt () {
    . ~/.mgtconfig
    local cur prev opts

    COMPREPLY=()   # Array variable storing the possible completions.
    cur=${COMP_WORDS[COMP_CWORD]}
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="init project task category config tag comment"

    ### required to make completion on 'tag' (else 'tag' which is $cur is not consumed
    [[ $COMP_CWORD -eq 1 ]] && { COMPREPLY=( $(compgen -W "${opts}" -- ${cur} ) ) ; return 0; }

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
        tag)
            _mgt_tag
            ;;
        comment)
            _mgt_comment
            ;;
        *)
            COMPREPLY=( $(compgen -W "${opts}" -- ${cur} ) )
            return 0
            ;;
    esac
}

#complete -F _mgt -o filenames mgt.sh
complete -F _mgt mgt.sh
complete -F _mgt mgt
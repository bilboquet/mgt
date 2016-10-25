#!/bin/bash

if [ -e ~/.mgtconfig ]; then
    . ~/.mgtconfig
else
    mgt -h
fi

find_category() {
    ### $1 = task_id
    return find $MGT_PROJECT_PATH -name $1 -printf %P | tr -s '/' ' ' | cut -f1 -d' '
}

usage_task () {
    echo "usage: mgt task grep [--filter <criteria>] [-i --interactive]"
    echo "       mgt task add [-c <category=todo>] [-T <tag_comma_separated_list>] -d <description>"
    echo "       mgt task mv --from <category> --to <category> --task <task_id>"
    echo "       mgt task edit -c <category> --task <task_id>"
    echo "       mgt task assign -c <category> --task <task_id> -u <username <user@server>>"
    echo "       mgt task rm --task <task_id>"
    echo "       mgt task --help"
}

usage_task_add() {
    echo "usage: mgt task add <options>"
    echo "  Options:"
    echo "    -c,--category <category>       If this option is missing, the category is set t othe default one"
    echo "    -T,--tags     <tag0,.., tagN>  Set tags on the newly addd task"
    echo "    -d,--description               Task description"
}

usage_task_search() {
    echo "usage: mgt task search <options>"
    echo "  Options:"
    echo "    -c,--category <category> Search in <category>"
    echo "    -f,--filter <filter>     Filtering criteria"
    echo "    -i,--interactive         Interactive search"
}

usage_task_mv() {
    echo "usage: mgt task mv <options>"
    echo "  Options:"
    echo "    -t,--task <task_id>    Task to move"
    echo "    --from <category>      From <category>"
    echo "    --to <category>        To <category>"
}

usage_task_edit() {
    echo "usage: mgt task edit <options>"
    echo "  Options:"
    echo "    -t,--task <task_id>      Task to edit"
    echo "    -c,--category <category> Category of the task to edit"
}

usage_task_view() {
    echo "usage: mgt task view <options>"
    echo "  Options:"
    echo "    -t,--task <task_id>      Task to view"
    echo "    -c,--category <category> Category of the task to view"
}

usage_task_depends() {
    echo "usage: mgt task depends --on 'dependency_task' --task 'task'"
    echo "  Options:"
    echo "    -c,--category <category>  Category of the view"
    echo "    -t,--task <task>          Task that has a dependency"
    echo "    -o,--on   <task>          The blocking task (only the 'task_id')"
}

usage_task_estimate() {
    echo "usage: mgt task estimate <options>"
    echo "  Options:"
    echo "    -t,--task <task_id>      Task to estimate"
    echo "    -c,--category <category> Category of the task"
    echo "    -e,--estimation <value>  Task estimation"
}

usage_task_remaining() {
    echo "usage: mgt task remaining <options>"
    echo "  Options:"
    echo "    -t,--task <task_id>      Task to estimate the remaining"
    echo "    -c,--category <category> Category of the task"
    echo "    -r,--remaining <value>   Task estimation of the remaining"
}

if [ -z "$1" ]; then
    usage_task
fi

case $1 in
    --help|-h)
        usage_task
        exit 0
        ;;

    view)
        shift
        argv=$(getopt -o c:t: -l category:,task: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_view
                    exit 1
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: category: '$category' does not exists."
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$category/$task_id' does not exists."
            exit 1
        fi

        cat "$MGT_PROJECT_PATH/$category/$task_id"
        ;;

    search)
        shift # consume list
        grep_filter=""
        argv=$(getopt -o f:c:ia -l filter:,category:,interactive -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            case "$1" in
                -c|--category)
                    category="$2"
                    shift
                    ;;
                -f|--filter)
                    keyword=$(echo "$2" | sed -s 's/\(.*\)=.*/\1/')
                    value=$(echo "$2" | sed -s 's/.*=\(.*\)/\1/')
                    ### TODO: decide if we want an OR or AND filter
                    grep_filter="$grep_filter -e \"$keyword: .*$value\""
                    shift
                    ;;
                -i|--interactive)
                    interactive=1
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_search
                    exit 1
                    ;;
            esac
            shift
        done

        if [ -z "$grep_filter" ]; then
            # in case of empty filter, add a "match all" filter
            grep_filter="-e \"Description: \""
        fi 
        cmd="grep -iHr $grep_filter $MGT_PROJECT_PATH/$category | sed 's!$MGT_PROJECT_PATH/\([^: ]*\):.*!\1!g' | sort -u"
        eval task_list=\$\($cmd\)
        
        for task in $task_list; do
            grep_filter="Description: "
            cmd="grep -e $grep_filter $MGT_PROJECT_PATH/$task | sed 's!$grep_filter!!'"
            eval task_details=\$\($cmd\)
            echo "##" $task": "$task_details
            if [ ! -z $interactive ]; then
                while [ true ]; do
                    echo
                    echo "(q)uit, (n)ext, (s)how details, (a)ssign to me, (h)istory."
                    read input
                    case $input in
                        q|quit)
                            break 2
                            ;;
                        ""|n|next)
                            break
                            ;;
                        s|show)
                            echo "######################################"
                            cat $MGT_PROJECT_PATH/$task
                            echo "######################################"
                            ;;
                        a)
                            mgt task assign -c ${task%/*} --task ${task##*/} -u "$(git config user.name) <$(git config user.email)>"
                            ;;
                        h|history)
                            $GIT log $MGT_PROJECT_PATH/$task
                            ;;
                        *)
                            ;;
                    esac
                done
            fi
        done
        ;;

    add)
        shift
        argv=$(getopt -o c:T:d: -l category:,tags:,description: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -T|--tags)
                    tags="$2"
                    ;;
                -d|--description)
                    description="$2"
                    ;;
                --)
                    break
                    ;;
                *)
                    usage_task_add
                    exit 1
                    ;;
            esac
            shift 2
        done

        if [ -z "$category" ]; then
            category=$(grep -e \* $MGT_CONF_PATH/categories | cut -f 1 -d':')
            echo "$category"
        fi
        if [ -z "$description" ]; then
            usage_task
            echo "Missing description"
            exit 1
        fi

        task_id=$(expr $(cat $MGT_CONF_PATH/task_id) + 1)
        echo -n "$task_id" > $MGT_CONF_PATH/task_id
        mkdir -p "$MGT_PROJECT_PATH/$category"
        echo "Task-Id: $task_id" > "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Author: $(git config user.name) <$(git config user.email)>" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Assignee: None" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Date: $(date)" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Estimation: None" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Remaining: None" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Tags: $tags" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Depends: None" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "Description: $description" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "" >> "$MGT_PROJECT_PATH/$category/$task_id"
        echo "# Long description" >> "$MGT_PROJECT_PATH/$category/$task_id"
        $EDITOR "$MGT_PROJECT_PATH/$category/$task_id"
        if [ $? -ne 0 ]; then
            exit 1
        fi
        sed -i -e '/^\s*#.*$/d' "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT add "$MGT_CONF_PATH/task_id" "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): add: $category/$task_id" -m "$description"
        echo "Task: $category/$task_id added successfully"
        ;;

    mv)
        shift
        argv=$(getopt -o t: -l task:,to:,from: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            ### TODO: Validate arguments
            case "$1" in
                --from)
                    from="$2"
                    ;;
                --to)
                    to="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_mv
                    exit 1
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$from" ]; then
            echo "mgt: category: '$from' does not exists."
            exit 1
        fi
        if [ ! -d "$MGT_PROJECT_PATH/$to" ]; then
            echo "mgt: category: '$to' does not exists."
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$from/$task_id" ]; then
            echo "mgt: task: '$from/$task_id' does not exists."
            exit 1
        fi

        $GIT mv "$MGT_PROJECT_PATH/$from/$task_id" "$MGT_PROJECT_PATH/$to"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): move: '$from/$task_id' => '$to/$task_id'"
        ;;

    edit)
        shift

        argv=$(getopt -o c:t: -l category:,task: -- "$@")
        eval set -- "$argv"
        while [ true ]; do

            ### TODO: Validate arguments
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    break
                    ;;
                *)
                    usage_task_edit
                    exit 1
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: category: '$category' does not exists."
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$category/$task_id' does not exists."
            exit 1
        fi

        $EDITOR "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): edit: $category/$task_id"
        ;;

    rm)
        while [ true ]; do
            shift

            ### TODO: Validate arguments
            case $1 in
                -c|--category)
                    category=$2
                    ;;
                --task)
                    shift
                    task_id=$1
                    break
                    ;;
                *)
                    echo "mgt: task: unknown option '$1'"
                    break
                    ;;
            esac
            shift
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: category: '$category' does not exists."
            exit 1
        fi

        if [ ! -f "$MGT_PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$category/$task_id' does not exists."
            exit 1
        fi
        $GIT rm "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): remove: $category/$task_id"
        ;;

    assign)
        shift
        argv=$(getopt -o c:t:u: -l category:,task:,username: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            ### TODO: Validate arguments
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    ;;
                -u|--username)
                    username="$2"
                    break
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_assign
                    break
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: task: category '$category' not found"
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$task_id' not found"
            exit 1
        fi

        sed -i "s/Assignee:\(.*\)/Assignee: $username/" $MGT_PROJECT_PATH/$category/$task_id
        $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): assign: $category/$task_id to $username"
        ;;

    depends)
        shift
        argv=$(getopt -o c:t:o: -l category:,task:,on: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            ### TODO: Validate arguments
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    ;;
                -o|--on)
                    dep="$2"
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_depends
                    break
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: task: '$category' not found"
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$category/$task" ]; then
            echo "mgt: task: '$task' not found"
            exit 1
        fi

        deps=$(grep -e 'Depends: None')
        if [ -z "$deps" ]; then
            deps=$(grep -e 'Depends: ' | grep $on)
            if [ -z "$deps" ]; then
                sed -i "s!Depends: \(.*\)$!Depends: \1, $on!" $MGT_PROJECT_PATH/$category/$task_id
            fi
        else
            sed -i "s!Depends: None!Depends: $on!" $MGT_PROJECT_PATH/$category/$task_id
        fi
        $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): depends: $category/$task_id depends on $on"        
        ;;

    tag)
        ### TODO: Edit task file
        ;;

    estimate)
        shift
        argv=$(getopt -o c:t:e: -l category:,task:,estimation: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            ### TODO: Validate arguments
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    ;;
                -e|--estimation)
                    estimation="$2"
                    break
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_estimate
                    break
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: task: category '$category' not found"
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$task_id' not found"
            exit 1
        fi

        sed -i "s/Estimation:\(.*\)/Estimation: $estimation/" $MGT_PROJECT_PATH/$category/$task_id
        $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): estimation: Estimate for $category/$task_id is $estimation"
        ;;

    remaining)
        shift
        argv=$(getopt -o c:t:r: -l category:,task:,remaining: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            ### TODO: Validate arguments
            case "$1" in
                -c|--category)
                    category="$2"
                    ;;
                -t|--task)
                    task_id="$2"
                    ;;
                -r|--remaining)
                    remaining="$2"
                    break
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_task_remaining
                    break
                    ;;
            esac
            shift 2
        done

        if [ ! -d "$MGT_PROJECT_PATH/$category" ]; then
            echo "mgt: task: category '$category' not found"
            exit 1
        fi
        if [ ! -f "$MGT_PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$task_id' not found"
            exit 1
        fi

        sed -i "s/Remaining:\(.*\)/Remaining: $remaining/" $MGT_PROJECT_PATH/$category/$task_id
        $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
        $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): remaining: Remaining for $category/$task_id is $remaining"
        ;;

    comment)
        ### TODO: use git-notes
        ;;

    *)
        usage_task
        exit 1
        ;;
esac

exit 0

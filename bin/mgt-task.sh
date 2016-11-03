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
    echo "usage: mgt task search [--filter <criteria>] [-i --interactive]"
    echo "       mgt task add [-c <category=todo>] [-T <tag_comma_separated_list>] -d <description>"
    echo "       mgt task mv --from <category> --to <category> --task <task_id>"
    echo "       mgt task edit -c <category> --task <task_id>"
    echo "       mgt task assign -c <category> --task <task_id> -u <username <user@server>>"
    echo "       mgt task rm --task <task_id>"
    echo "       mgt task history -c <category> --task <task_id>"
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
    echo "usage: mgt task depends --on 'dependency_task' --ndep 'dependency to remove' --task 'task'"
    echo "  Options:"
    echo "    -c,--category <category>  Category of the view"
    echo "    -t,--task <task>          Task that has a dependency"
    echo "    -o,--on   <task >*        The blocking task (only the 'task_id')"
    echo "    --ndep    <task >*        Remove a dependency to the given task (only the 'task_id')"
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

# Return 0 if $1 is a defined category
# else print a message and return 1
function exist_category () {
    if [ ! -d "$MGT_PROJECT_PATH/$1" ]; then
        echo "mgt: category: '$1' not found"
        return 1
    fi
    return 0
}

# Return 0 if $1 is a defined task AND $2 is a defined category
# else print a message and return 1
function exist_task_in_cat () {
    if exist_category "$2" ; then
         if [ -f "$MGT_PROJECT_PATH/$category/$1" ]; then
            return 0
        else
            echo "mgt: task: '$1' not found"
            return 1
        fi
    fi
    return 1
}

# Return 0 if $1 is a defined task 
function exist_task () {
    task=$(find "$MGT_PROJECT_PATH" -name "$1")
    if [ -e "$task" ]; then 
        return 0 
    fi
    return 1
}

function mgt_task_view () {
    argv=$(getopt -o c:t: -l category:,task: -- "$@")
    eval set -- "$argv"
    while [ true ]; do
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            -t|--task)
                if exist_task "$2"; then
                    task_id="$2"
                else
                    echo "mgt: task: '$2' not found"
                    exit 1
                fi
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

    if ! exist_task_in_cat $task_id $category ; then
        exit 1
    fi

    cat "$MGT_PROJECT_PATH/$category/$task_id"
    exit $?
}
function mgt_task_search () {
    grep_filter=""
    argv=$(getopt -o f:c:ia -l filter:,category:,interactive -- "$@")
    eval set -- "$argv"
    while [ true ]; do
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
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
    exit $?
}

function mgt_task_add () {
    argv=$(getopt -o c:T:d: -l category:,tags:,description: -- "$@")
    eval set -- "$argv"

    while [ true ]; do
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            -T|--tags)
                if exist_task "$2"; then
                    task_id="$2"
                else
                    echo "mgt: task: '$2' not found"
                    exit 1
                fi
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
    if [ -z $task_id ]; then
        echo "Error getting task id, check $MGT_CONF_PATH/task_id and configuration."
        exit 1
    fi
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
        ### TODO: improve testing, maybe we should decrease $MGT_CONF_PATH/task_id
        rm -f "$MGT_PROJECT_PATH/$category/$task_id"
        exit 1
    fi
    sed -i -e '/^\s*#.*$/d' "$MGT_PROJECT_PATH/$category/$task_id"
    $GIT add "$MGT_CONF_PATH/task_id" "$MGT_PROJECT_PATH/$category/$task_id"
    $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): add: $category/$task_id" -m "$description"
    echo "Task: $category/$task_id added successfully"
}

function mgt_task_mv () {
argv=$(getopt -o t: -l task:,to:,from: -- "$@")
eval set -- "$argv"
while [ true ]; do
    ### TODO: Validate arguments
    case "$1" in
        --from)
            if exist_category "$2"; then
                from="$2"
            else
                exit 1
            fi
            ;;
        --to)
            if exist_category "$2"; then
                to="$2"
            else
                exit 1
            fi
            ;;
        -t|--task)
            if exist_task "$2"; then
                task_id="$2"
            else
                echo "mgt: task: '$2' not found"
                exit 1
            fi
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

if ! exist_task_in_cat $task_id $from ; then
    exit 1
fi
if [ ! -d "$MGT_PROJECT_PATH/$to" ]; then
    echo "mgt: category: '$to' does not exists."
    exit 1
fi

$GIT mv "$MGT_PROJECT_PATH/$from/$task_id" "$MGT_PROJECT_PATH/$to"
$GIT commit -s -m "$(cat $MGT_CONF_PATH/project): move: '$from/$task_id' => '$to/$task_id'"
exit $?
}

function mgt_task_edit () {
argv=$(getopt -o c:t: -l category:,task: -- "$@")
eval set -- "$argv"
while [ true ]; do

    ### TODO: Validate arguments
    case "$1" in
        -c|--category)
            if exist_category "$2"; then
                category="$2"
            else
                exit 1
            fi
            ;;
        -t|--task)
            if exist_task "$2"; then
                task_id="$2"
            else
                echo "mgt: task: '$2' not found"
                exit 1
            fi
            break
            ;;
        *)
            usage_task_edit
            exit 1
            ;;
    esac
    shift 2
done

if ! exist_task_in_cat $task_id $category ; then
    exit 1
fi

$EDITOR "$MGT_PROJECT_PATH/$category/$task_id"
$GIT add "$MGT_PROJECT_PATH/$category/$task_id"
$GIT commit -s -m "$(cat $MGT_CONF_PATH/project): edit: $category/$task_id"
exit $?
}

function mgt_task_rm () {
### TODO: rewrite using getopt
    while [ true ]; do
        shift
        case $1 in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            --task)
                shift
                if exist_task "$1"; then
                    task_id="$1"
                else
                    echo "mgt: task: '$1' not found"
                    exit 1
                fi
                break
                ;;
            *)
                echo "mgt: task: unknown option '$1'"
                break
                ;;
        esac
        shift
    done

    if ! exist_task_in_cat $task_id $category ; then
        exit 1
    fi

    $GIT rm "$MGT_PROJECT_PATH/$category/$task_id"
    $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): remove: $category/$task_id"
    exit $?
}

function mgt_task_assign () {
argv=$(getopt -o c:t:u: -l category:,task:,username: -- "$@")
eval set -- "$argv"
while [ true ]; do
    ### TODO: Validate arguments
    case "$1" in
        -c|--category)
            if exist_category "$2"; then
                category="$2"
            else
                exit 1
            fi
            ;;
        -t|--task)
            if exist_task "$2"; then
                task_id="$2"
            else
                echo "mgt: task: '$2' not found"
                exit 1
            fi
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

if ! exist_task_in_cat $task_id $category ; then
    exit 1
fi

sed -i "s/Assignee:\(.*\)/Assignee: $username/" $MGT_PROJECT_PATH/$category/$task_id
$GIT add "$MGT_PROJECT_PATH/$category/$task_id"
$GIT commit -s -m "$(cat $MGT_CONF_PATH/project): assign: $category/$task_id to $username"
    exit $?
}

function mgt_task_depends () {
    argv=$(getopt -o c:t:o: -l category:,task:,on:,ndep: -- "$@")
    eval set -- "$argv"
    local on task_id category ndep
    while [ true ]; do
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            -t|--task)
                if exist_task "$2"; then
                    task_id="$2"
                else
                    echo "mgt: task: '$2' not found"
                    exit 1
                fi
                ;;
            -o|--on)
                on="$on,"$2
                ;;
            --ndep)
                ndep="$ndep,"$2
                ;;
            --)
                shift
                break
                ;;
            *)
                usage_task_depends
                exit 1
                ;;
        esac
        shift 2
    done

    if ! exist_task_in_cat $task_id $category ; then
        exit 1
    fi

    on=${on//,/ }
    ndep=${ndep//,/ }

    # check that tasks given as --on and --ndep exist
    read -ra deps <<< "$on $ndep"
    for s_dep in "${deps[@]}"; do
        if ! exist_task "$s_dep"; then
        echo "mgt: task: '$s_dep' not found"
        exit 1
    fi
    done



    deps=$(grep -e 'Depends: None' "$MGT_PROJECT_PATH/$category/$task_id")
    if [ -z "$deps" ]; then # some deps found
        # get old deps
        deps=$(grep -e 'Depends: ' "$MGT_PROJECT_PATH/$category/$task_id" | sed -e "s|Depends: \(.*\)$|\1|")
        # merge old and new deps
        read -ra new_deps <<< "$on $deps"
        # remove duplicates
        on=( $(printf "%s\n" "${new_deps[@]}" | sort -nu) )
        # flatten
        on=$(echo ${on[@]})
        
        ### remove $ndep
        # loop on all deps to be removed
        read -ra rm_deps <<< "$ndep"
        for s_dep in "${rm_deps[@]}"; do
            #remove s_dep from deps
            on=$(echo $on | sed -e "s/\<$s_dep\>//g")
        done

        if [ "$on" == "" ]; then
            #no deps anymore
            on="None"
        fi
        #update deps 
        sed -i "s|Depends: .*$|Depends: $on|" $MGT_PROJECT_PATH/$category/$task_id

    else # no deps yet
        sed -i "s!Depends: None!Depends: $on!" $MGT_PROJECT_PATH/$category/$task_id
    fi
    $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
    $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): depends: $category/$task_id depends on $on"
    exit $?
}

function mgt_task_estimate () {
    argv=$(getopt -o c:t:e: -l category:,task:,estimation: -- "$@")
    eval set -- "$argv"
    while [ true ]; do
        ### TODO: Validate arguments
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            -t|--task)
                if exist_task "$2"; then
                    task_id="$2"
                else
                    echo "mgt: task: '$2' not found"
                    exit 1
                fi
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

    if ! exist_task_in_cat $task_id $category ; then
        exit 1
    fi

    sed -i "s/Estimation:\(.*\)/Estimation: $estimation/" $MGT_PROJECT_PATH/$category/$task_id
    $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
    $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): estimation: Estimate for $category/$task_id is $estimation"
    exit $?
}

function mgt_task_remaining () {
    argv=$(getopt -o c:t:r: -l category:,task:,remaining: -- "$@")
    eval set -- "$argv"
    while [ true ]; do
        ### TODO: Validate arguments
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            -t|--task)
                if exist_task "$2"; then
                    task_id="$2"
                else
                    echo "mgt: task: '$2' not found"
                    exit 1
                fi
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

    if ! exist_task_in_cat $task_id $category ; then
        exit 1
    fi

    sed -i "s/Remaining:\(.*\)/Remaining: $remaining/" $MGT_PROJECT_PATH/$category/$task_id
    $GIT add "$MGT_PROJECT_PATH/$category/$task_id"
    $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): remaining: Remaining for $category/$task_id is $remaining"
    exit $?
}

function mgt_task_history () {
    set -x
    argv=$(getopt -o c:t: -l category:,task: -- "$@")
    eval set -- "$argv"
    while [ true ]; do
        ### TODO: Validate arguments
        case "$1" in
            -c|--category)
                if exist_category "$2"; then
                    category="$2"
                else
                    exit 1
                fi
                ;;
            -t|--task)
                if exist_task "$2"; then
                    task_id="$2"
                else
                    echo "mgt: task: '$2' not found"
                    exit 1
                fi
                ;;
            --)
                shift
                break
                ;;
            *)
                usage_task
                break
                ;;
        esac
        shift 2
    done
    $GIT log "$MGT_PROJECT_PATH/$category/$task_id"
    exit $?
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
        mgt_task_view "$@"
        ;;
    search)
        shift # consume list
        mgt_task_search "$@"
        ;;
    add)
        shift
        mgt_task_add "$@"
        ;;
    mv)
        shift
        mgt_task_mv "$@"
        ;;
    edit)
        shift
        mgt_task_edit "$@"
        ;;
    rm)
        mgt_task_rm "$@"
        ;;
    assign)
        shift
        mgt_task_assign "$@"
        ;;
    depends)
        shift
        mgt_task_depends "$@"
        ;;
    tag)
        ### TODO: Edit task file
        ;;
    estimate)
        shift
        mgt_task_estimate "$@"
        ;;
    remaining)
        shift
        mgt_task_remaining "$@"
        ;;
    history)
        shift
        mgt_task_history "$@"
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

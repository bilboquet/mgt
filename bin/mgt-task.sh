#!/bin/bash

GIT_WTREE=~/.mgt
PROJECT_PATH=$GIT_WTREE/project

find_category() {
    ### $1 = task_id
    return find $PROJECT_PATH -name $1 -printf %P | tr -s '/' ' ' | cut -f1 -d' '
}

usage () {
    echo "usage: mgt task list -ta--filter <criteria>"
    echo "       mgt task create -c <category> -t <tag_comma_separated_list> -d <description>"
    echo "       mgt task move --from <category> --to <category> --task <task_id>"
    echo "       mgt task edit -c <category> --task <task_id>"
    echo "       mgt task assign -c <category> --task <task_id> -u <username <user@server>"
    echo "       mgt task rm --task <task_id>"
    echo "       mgt task --help"
}

if [ -z "$1" ]; then
    usage
fi

case $1 in
    --help|-h)
        usage
        exit 0
        ;;
    list)
        grep_filter=""
                while [ true ]; do
                        shift

            if [ -z "$1" ]; then
                break;
            fi
                        case $1 in
                                -f|--filter)
                    keyword=$(echo $2 | sed -s 's/\(.*\)=.*/\1/')
                    value=$(echo $2 | sed -s 's/.*=\(.*\)/\1/')
                                        grep_filter="$grep_filter -e \"$keyword: .*$value\""
                                        ;;
                                *)
                                        echo "mgt: task: unknown option '$1'"
                                        break
                                        ;;
                        esac
                        shift
                done

        cmd="grep -iHr $grep_filter $PROJECT_PATH | sed 's!$PROJECT_PATH/\([^: ]*\):.*!\1!g'"
        eval $cmd
        ;;
    create)
                while [ true ]; do
                        shift

                        ### TODO: Validate arguments
                        case $1 in
                                -c|--category)
                                        category=$2
                                        ;;
                                -t|--tag)
                                        tag=$2
                                        ;;
                                -d|--description)
                                        shift
                                        description="$@"
                                        break
                                        ;;
                                *)
                                        echo "mgt: task: unknown option '$1'"
                                        break
                                        ;;
                        esac
                        shift
                done

                if [ -z "$category" ]; then
                        usage
                        exit 1
                fi
                if [ -z "$description" ]; then
                        usage
                        exit 1
                fi

                task_id=$(expr $(cat $GIT_WTREE/conf.d/task_id) + 1)
                echo -n "$task_id" > $GIT_WTREE/conf.d/task_id
                echo "Task-Id: $task_id" > "$PROJECT_PATH/$category/$task_id"
                echo "Author: $(git config user.name) <$(git config user.email)>" >> "$PROJECT_PATH/$category/$task_id"
                echo "Assignee: None" >> "$PROJECT_PATH/$category/$task_id"
                echo "Date: $(date)" >> "$PROJECT_PATH/$category/$task_id"
                echo "Estimation: None" >> "$PROJECT_PATH/$category/$task_id"
                echo "Remaining: None" >> "$PROJECT_PATH/$category/$task_id"
                echo "Tags: $tag" >> "$PROJECT_PATH/$category/$task_id"
                echo "Description: $description" >> "$PROJECT_PATH/$category/$task_id"
                echo "" >> "$PROJECT_PATH/$category/$task_id"
                echo "# Long description" >> "$PROJECT_PATH/$category/$task_id"
                $EDITOR "$PROJECT_PATH/$category/$task_id"
                if [ $? -ne 0 ]; then
                        exit 1
                fi
                sed -i -e 's/^\s*#.*$/d' "$PROJECT_PATH/$category/$task_id"
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE add "$GIT_WTREE/conf.d/task_id" "$PROJECT_PATH/$category/$task_id"
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE commit -s -m "$(cat $GIT_WTREE/conf.d/project): create: $category/$task_id" -m "$description"
                echo "Task: $category/$task_id created successfully"
                ;;
    move)
                while [ true ]; do
                        shift

                        ### TODO: Validate arguments
                        case $1 in
                                -f|--from)
                                        from=$2
                                        ;;
                                -t|--to)
                                        to=$2
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

                if [ -z "$category" ]; then
                        usage
                        exit 1
                fi
                if [ -z "$description" ]; then
                        usage
                        exit 1
                fi

                if [ ! -d "$PROJECT_PATH/$from" ]; then
                        echo "mgt: category: '$from' does not exists."
                        exit 1
                fi
                if [ ! -d "$PROJECT_PATH/$to" ]; then
                        echo "mgt: category: '$to' does not exists."
                        exit 1
                fi
                if [ ! -f "$PROJECT_PATH/$from/$task_id" ]; then
                        echo "mgt: task: '$from/$task_id' does not exists."
                        exit 1
                fi

                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE mv "$PROJECT_PATH/$from/$task_id" "$PROJECT_PATH/$to"
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE commit -s -m "$(cat $GIT_WTREE/conf.d/project): move: '$from/$task_id' => '$to/$task_id'"
        ;;
    edit)
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

                if [ ! -d "$PROJECT_PATH/$category" ]; then
                        echo "mgt: category: '$category' does not exists."
                        exit 1
                fi
                if [ ! -f "$PROJECT_PATH/$category/$task_id" ]; then
                        echo "mgt: task: '$category/$task_id' does not exists."
                        exit 1
                fi

                $EDITOR "$PROJECT_PATH/$category/$task_id"
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE add "$PROJECT_PATH/$category/$task_id"
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE commit -s -m "$(cat $GIT_WTREE/conf.d/project): edit: $category/$task_id"
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

                if [ ! -d "$PROJECT_PATH/$category" ]; then
                        echo "mgt: category: '$category' does not exists."
                        exit 1
                fi

                if [ ! -f "$PROJECT_PATH/$category/$task_id" ]; then
                        echo "mgt: task: '$category/$task_id' does not exists."
                        exit 1
                fi
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE rm "$PROJECT_PATH/$category/$task_id"
                git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE commit -s -m "$(cat $GIT_WTREE/conf.d/project): remove: $category/$task_id"
        ;;
        assign)
                while [ true ]; do
                        shift

                        ### TODO: Validate arguments
                    case $1 in
                                -c|--category)
                                        category=$2
                                        ;;
                                --task)
                                        task_id=$2
                                        ;;
                                -u|---username)
                    shift
                                        username=$@
                    break
                                    ;;
                                *)
                                        echo "mgt: task: unknown option '$1'"
                                        break
                                        ;;
                        esac
                        shift
                done

        if [ ! -d "$PROJECT_PATH/$category" ]; then
            echo "mgt: task: category '$category' not found"
            exit 1
        fi
        if [ ! -f "$PROJECT_PATH/$category/$task_id" ]; then
            echo "mgt: task: '$task_id' not found"
            exit 1
        fi

        sed -i "s/Assignee:\(.*\)/Assignee: $username/" $PROJECT_PATH/$category/$task_id
        git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE add "$PROJECT_PATH/$category/$task_id"
        git --git-dir=$GIT_WTREE/.git --work-tree=$GIT_WTREE commit -s -m "$(cat $GIT_WTREE/conf.d/project): assign: $category/$task_id to $username"
                ;;
        tag)
                ### TODO: Edit task file
                ;;
        estimate)
                ### TODO: Edit task file
                ;;
        remaining)
                ### TODO: Edit task file
                ;;
        comment)
                ### TODO: use git-note
                ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0

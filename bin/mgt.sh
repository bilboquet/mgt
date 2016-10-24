#!/bin/bash
#set -x
PATH=$PATH:$(dirname $0)

usage () {
    echo "usage: mgt init <-h|--help> -n|--new -r|--remote <remote> [--force]"
    echo "       mgt project <-h|--help|init|list|select|sync> ..."
    echo "       mgt task <-h|--help|create|move|edit||comment|tag|rm|filter> ..."
    echo "       mgt category <-h|--help|create|edit|rm|filter> ..."
    echo "       mgt config <-h|--help|-l|--list|set|get> ..."
}

if [ -z "$EDITOR" ]; then
    echo "Please set default editor using EDITOR environement variable"
fi

case $1 in
    init)
        shift # consume 'init'
        while [ $# -gt 0 ]; do
            ### TODO: Validate arguments
            case $1 in
                -r|--remote)
                    remote=$2
                    shift #consume param remote
                    ;;
                -n|--new)
                    new=yes
                    ;;
                --force)
                    force=$1
                    ;;
                *)
                    echo "mgt: unknown option '$1'"
                    break
                    ;;
            esac
            shift #next arg
        done

        if [ ! -e ~/.mgtconfig ]; then 
            touch ~/.mgtconfig
            echo '### Do not modify' >> ~/.mgtconfig
            echo '### Variables' >> ~/.mgtconfig
            echo 'MGT_PATH=~/.mgt' >> ~/.mgtconfig
            echo 'MGT_CONF_PATH=$MGT_PATH/conf.d' >> ~/.mgtconfig
            echo 'MGT_PROJECT_PATH=$MGT_PATH/project' >> ~/.mgtconfig
            echo '### Commands' >> ~/.mgtconfig
            echo 'GIT="git --work-tree=$MGT_PATH --git-dir=$MGT_PATH/.git"' >> ~/.mgtconfig
        else
            echo "~/.mgtconfig already exists, won't modify it."
        fi

        . ~/.mgtconfig

        if [ ! -z "$new" ]; then
            mkdir -p $MGT_PATH/conf.d
            mkdir -p $MGT_PATH/project
            echo "mgt repository" > $MGT_PATH/README
            $GIT init
            echo "mgt: project management" > $MGT_PATH/.git/description
            $GIT add .
            $GIT commit -s -m "Project: create project management repository"
            if [ ! -z "$remote" ]; then
                if [ -z "$force" ]; then
                    echo -n "You use --new combined with --remote without "
                    echo -n "--force. <remote> won't be overwritten which "
                    echo "is safe but may result in an error."
                fi
                $GIT remote remove origin
                $GIT remote add origin $remote
                $GIT push "$force" origin master
            fi
        else
            if [ ! -z "$remote" ]; then
                git clone $remote $MGT_PATH
            else
                echo " *** You specified a not new remote: --remote is then mandatory..."
                echo ""
                usage
                exit 1
            fi
        fi
        ;;
    project)
        shift
        mgt-project.sh $@
        ;;
    task)
        shift
        mgt-task.sh $@
        ;;
    category)
        shift
        mgt-category.sh $@
        ;;
    config)
        shift
        mgt-config.sh $@
        ;;
    -h|--help)
        usage
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit $?

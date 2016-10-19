#!/bin/bash
#set -x
PATH=$PATH:$(dirname $0)

. common.sh

usage () {
    echo "usage: mgt init <-h|--help> -r <remote>"
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
                shift #consume -r
                shift #consume remote
                ;;
                *)
                echo "mgt: unknown option '$1'"
                break
                ;;
            esac
            shift
        done

        mkdir -p $GIT_WTREE/conf.d
        mkdir -p $GIT_WTREE/project
        $GIT init
        echo "mgt: project management" > $GIT_WTREE/.git/description
        $GIT add .
        $GIT commit -s -m "Project: create project management repository"
        if [ ! -z "$remote" ]; then
            $GIT remote remove origin
            $GIT remote add origin $remote
            $GIT push origin master
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

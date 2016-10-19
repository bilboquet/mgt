#!/bin/bash

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
        while [ true ]; do
            shift

            ### TODO: Validate arguments
            case $1 in
                -r|--remote)
                remote=$2
                break
                ;;
                *)
                echo "mgt: unknown option '$1'"
                break
                ;;
            esac
            shift
        done

        GIT_WTREE=~/.mgt
        mkdir -p $GIT_WTREE/conf.d
        mkdir -p $GIT_WTREE/project
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git init
        echo "mgt: project management" > $GIT_WTREE/.git/description
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git add .
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git commit -s -m "Project: create project management repository"
        if [ ! -z "$1" ]; then
            git remote add origin "$1"
            git push origin master
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

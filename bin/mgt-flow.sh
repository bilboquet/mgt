#!/bin/bash

GIT_WTREE=~/.mgt

usage () {
    echo "usage: mgt flow create --from <name>"
    echo "       mgt project list"
    echo "       mgt project select <name>"
    echo "       mgt project sync"
}

if [ -z "$1" ]; then
    usage
fi

case $1 in
    -h|--help)
        usage
        exit 0
        ;;
    init)
        shift
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git checkout -b "$1"
        if [ $? -ne 0 ]; then
            return 1
        fi
        echo "$1 - $(whoami)" > $GIT_WTREE/conf.d/description
        echo -n "$1" > $GIT_WTREE/conf.d/project
        echo -n "$(whoami)" > $GIT_WTREE/conf.d/owner
        echo -n "0" >  $GIT_WTREE/conf.d/task_id
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git add .
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git commit -s -m "Project: create project '$1'"
        ;;
    list)
        git --git-dir=$GIT_WTREE/.git branch -l | grep -v master
        ;;
    select)
        git --git-dir=$GIT_WTREE/.git checkout "$1"
        $remote = $(git remote | grep origin)
        if [ ! -z "$remote" ]; then
            git --git-dir=$GIT_WTREE/.git --work-dir=$GIT_WTREE pull --rebase
        fi
        ;;
    sync)
        $remote = $(git remote | grep origin)
        if [ ! -z "$remote" ]; then
            git --git-dir=$GIT_WTREE/.git --work-dir=$GIT_WTREE pull --rebase
            git --git-dir=$GIT_WTREE/.git push
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0

#!/bin/bash

GIT_WTREE=~/.mgt

usage () {
    echo "usage: mgt project init <name>"
    echo "       mgt project list"
    echo "       mgt project select <name>"
    echo "       mgt project sync"
}

create_initial_tags() {
    echo "enhancement:Enhancement" > "$1"
    echo "bug:Bug" >> "$1"
    echo "duplicate:Duplicate" >> "$1"
    echo "question:Question" >> "$1"
    echo "invalid:Invalid" >> "$1"
    echo "wontfix:Won't Fix" >> "$1"
    echo "helpwanted:Help Wanted" >> "$1"
}

create_initial_users() {
    echo "$(whoami):$(git config user.name) <$(git config user.email)>" > "$1"
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
        if [ -z "$1" ]; then
            echo "Project <name> cannot be empty"
            exit 1
        fi
        git --work-tree=$GIT_WTREE --git-dir=$GIT_WTREE/.git checkout -b "$1"
        if [ $? -ne 0 ]; then
            exit 1
        fi
        echo "$1 - $(whoami)" > $GIT_WTREE/conf.d/description
        echo -n "$1" > $GIT_WTREE/conf.d/project
        echo -n "$(whoami)" > $GIT_WTREE/conf.d/owner
        create_initial_tags $GIT_WTREE/conf.d/tags
        create_initial_users $GIT_WTREE/conf.d/users
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

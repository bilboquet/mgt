#!/bin/bash

if [ -e ~/.mgtconfig ]; then
    . ~/.mgtconfig
else
    mgt -h
fi

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

create_initial_categories() {
    echo "todo:Todo *" >> $1
    echo "done:Done" >> $1
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
        $GIT checkout -b "$1"
        if [ $? -ne 0 ]; then
            exit 1
        fi
        echo "$1 - $(whoami)" > $MGT_CONF_PATH/description
        echo -n "$1" > $MGT_CONF_PATH/project
        echo -n "$(whoami)" > $MGT_CONF_PATH/owner
        create_initial_tags $MGT_CONF_PATH/tags
        create_initial_users $MGT_CONF_PATH/users
        create_initial_categories $MGT_CONF_PATH/categories
        echo -n "0" >  $MGT_CONF_PATH/task_id
        $GIT add .
        $GIT commit -s -m "Project: create project '$1'"
        ;;
    list)
        $GIT branch -l | grep -v master
        ;;
    select)
        $GIT checkout "$1"
        remote=$($GIT remote | grep origin)
        if [ ! -z "$remote" ]; then
            $GIT pull --rebase
        fi
        ;;
    sync)
        remote=$($GIT remote | grep origin)
        if [ ! -z "$remote" ]; then
            $GIT pull --rebase origin master
            $GIT push --mirror
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0

#!/bin/bash

if [ -e ~/.mgtconfig ]; then
    . ~/.mgtconfig
else
    mgt -h
fi

usage_project () {
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
    echo "todo:Todo:*" >> $1
    mkdir -p $MGT_PROJECT_PATH/"todo"
    echo "done:Done:" >> $1
    mkdir -p $MGT_PROJECT_PATH/"done"
}

if [ -z "$1" ]; then
    usage_project
fi

mgt_project_init () {
    if [ -z "$1" ]; then
        echo "Project <name> cannot be empty"
        exit 1
    fi
    $GIT checkout -b "$1"
    if [ $? -ne 0 ]; then
        exit 1
    fi
#    remote=$($GIT remote | grep origin)
#    if [ ! -z "$remote" ]; then
#        $GIT branch --set-upstream-to=origin/"$1" "$1"
#        ret_val=$?
#        if [ $ret_val -ne 0 ]; then
#            exit $ret_val
#        fi
#    fi

    
    echo "$1 - $(whoami)" > $MGT_CONF_PATH/description
    echo -n "$1" > $MGT_CONF_PATH/project
    echo -n "$(whoami)" > $MGT_CONF_PATH/owner
    create_initial_tags $MGT_CONF_PATH/tags
    create_initial_users $MGT_CONF_PATH/users
    create_initial_categories $MGT_CONF_PATH/categories
    echo -n "0" >  $MGT_CONF_PATH/task_id
    $GIT add .
    $GIT commit -s -m "Project: create project '$1'"
    exit $?
}

mgt_project_select () {
    $GIT checkout "$1"
    ret_val=$?
    remote=$($GIT remote | grep origin)
    if [ ! -z "$remote" ]; then
        $GIT pull --rebase origin "$1"
        ret_val=$?
    fi
    exit $ret_val
}

mgt_project_sync () {
    remote=$($GIT remote | grep origin)
    if [ ! -z "$remote" ]; then
        ### FIXME: got a rebase error here, seem branch are getting mixed
        $GIT pull --rebase origin $(basename $(cat $MGT_PATH/.git/HEAD | sed 's!.*: \(.*\)!\1!'))
        #$GIT pull --rebase origin master
        ret_val=$?
        if [ $ret_val -ne 0 ]; then
            ### FIXME: add better error handling
            echo "Error while syncing, please fix rebase problem using git."
            exit $ret_val
        fi
        $GIT push origin $(basename $(cat $MGT_PATH/.git/HEAD | sed 's!.*: \(.*\)!\1!'))
        #$GIT push --mirror
        exit $?
    else
        usage_project
        exit 1
    fi
}

case $1 in
    -h|--help)
        usage_project
        exit 0
        ;;

    init)
        shift
        mgt_project_init "$@"
        ;;

    list)
        $GIT branch -l | grep -v master
        exit $?
        ;;

    select)
        shift
        mgt_project_select "$@"
        
        ;;

    sync)
        mgt_project_sync
        ;;

    --)
        shift
        break
        ;;
    *)
        usage_project
        exit 1
        ;;
esac

exit 0

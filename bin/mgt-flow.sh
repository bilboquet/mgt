#!/bin/bash

. ~/.mgtconfig

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
        git --work-tree=$MGT_PATH --git-dir=$MGT_PATH/.git checkout -b "$1"
        if [ $? -ne 0 ]; then
            return 1
        fi
        echo "$1 - $(whoami)" > $MGT_CONF_PATH/description
        echo -n "$1" > $MGT_CONF_PATH/project
        echo -n "$(whoami)" > $MGT_CONF_PATH/owner
        echo -n "0" >  $MGT_CONF_PATH/task_id
        git --work-tree=$MGT_PATH --git-dir=$MGT_PATH/.git add .
        git --work-tree=$MGT_PATH --git-dir=$MGT_PATH/.git commit -s -m "Project: create project '$1'"
        ;;
    list)
        git --git-dir=$MGT_PATH/.git branch -l | grep -v master
        ;;
    select)
        git --git-dir=$MGT_PATH/.git checkout "$1"
        $remote = $(git remote | grep origin)
        if [ ! -z "$remote" ]; then
            git --git-dir=$MGT_PATH/.git --work-dir=$MGT_PATH pull --rebase
        fi
        ;;
    sync)
        $remote = $(git remote | grep origin)
        if [ ! -z "$remote" ]; then
            git --git-dir=$MGT_PATH/.git --work-dir=$MGT_PATH pull --rebase
            git --git-dir=$MGT_PATH/.git push
        fi
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0

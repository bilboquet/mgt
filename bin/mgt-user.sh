#!/bin/bash
# Manage the known users
#

if [ -e ~/.mgtconfig ]; then
    . ~/.mgtconfig
else
    mgt -h
fi

usage() {
    echo "usage: mgt user list"
    echo "       mgt user add -n <login> -e <email> -u <username>"
    echo "       mgt user rm <user>"
    echo "       mgt user <-h|--help>"
}

usage_user_add() {
    echo "usage: mgt user add <options>"
    echo "  Options:"
    echo "    -n,--name            User identifier to add"
    echo "    -u,--username        User name"
    echo "    -e,--email           User email"
}

usage_user_mv() {
    echo "usage: mgt user mv <options>"
    echo "  Options:"
    echo "    -n,--name            User identifier to remove"
}

usage_user_list() {
    echo "usage: mgt user list"
}

if [ -z "$1" ]; then
    usage
fi

case "$1" in
    list)
        echo "name:username <email>"
        echo "---------------------"
        cat $MGT_CONF_PATH/users
        ;;

    add)
        shift # Consume 'create'
        argv=$(getopt -o n:u:e: -l name:,username:,email: -- "$@")
        eval set -- "$argv"
        while true; do
            case "$argv" in
                -n|--name)
                    name="$2"
                    ;;
                -e|--email)
                    email="$2"
                    ;;
                -u|--username)
                    username="$2"
                    ;;
                --)
                    shift
                    break;
                    ;;
                *)
                    usage_user_add
                    exit 1
            esac
        done

        echo "$name:$username <$email>" >> $MGT_CONF_PATH/categories
        $GIT add $MGT_CONF_PATH/users
        $GIT commit -s -m "users: Add $username <$email> as $name"
        ;;

    rm)
        shift
        argv=$(getopt -o n: -l name: -- "$@")
        eval set -- "$argv"
        while true; do
            case "$argv" in
                -n|--name)
                    name="$2"
                    ;;
                --)
                    shift
                    break;
                    ;;
                *)
                    usage_user_mv
                    exit 1
            esac
        done

        sed -i "/$1:/d" $MGT_CONF_PATH/users
        $GIT add $MGT_CONF_PATH/users
        $GIT commit -s -m "category: Remove $"
        ;;

    --help|-h)
        usage
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac

exit 0

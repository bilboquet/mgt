#!/bin/bash

GIT_WTREE=~/.mgt
PROJECT_PATH=$GIT_WTREE/project

usage () {
    echo "usage: mgt category list"
    echo "       mgt category create <category>"
    echo "       mgt category --help"
}

if [ -z "$1" ]; then
    usage
fi

case $1 in
    list)
                tree --noreport -d $PROJECT_PATH
        ;;
    create)
                shift
        mkdir -p $PROJECT_PATH/$1
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

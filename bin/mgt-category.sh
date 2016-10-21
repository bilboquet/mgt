#!/bin/bash
# Manage the category of your task
# Note: the categories are used in the workflow

. ~/.mgtconfig

usage () {
    echo "usage: mgt category list"
    echo "       mgt category create <category>"
    echo "       mgt category remove <category>"
    echo "       mgt category --help"
}

if [ -z "$1" ]; then
    usage
fi

case $1 in
    list)
	echo "mgt: categories"
	echo "category:label:default"
	cat $MGT_CONF_PATH/categories
        ;;
    create)
        shift
        mkdir -p $MGT_PROJECT_PATH/$1
        echo $1 >> $MGT_CONF_PATH/categories
        ;;
    remove)
        shift
        sed -i "'/$1/d'" $MGT_CONF_PATH/categories
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

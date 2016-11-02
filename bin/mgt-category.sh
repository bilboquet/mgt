#!/bin/bash
# Manage the category of your task
# Note: the categories are used in the workflow

. ~/.mgtconfig

usage_category () {
    echo "usage: mgt category list"
    echo "       mgt category add -l <label> [-d] -c <category>"
    echo "       mgt category rm <category>"
    echo "       mgt category --help"
}

if [ -z "$1" ]; then
    usage_category
    exit 1
fi

case "$1" in
    list)
	    echo "category:label:default"
        echo "----------------------"
	    cat $MGT_CONF_PATH/categories
        ;;

    add)
        shift # Consume 'create'

        argv=$(getopt -o c:,l:,d -l category:,label:,default -- "$@")
        eval set -- "$argv"
        while true; do
            case "$1" in
                -c)
                    category="$2"
                    shift
                    ;;
                -l)
                    label="$2"
                    shift
                    ;;
                -d)
                    default='*'
                    ;;
                --)
                    break
                    ;;
                *)
#                    usage_category_add
                    usage_category
                    exit 1
            esac
            shift
        done
        
        mkdir -p $MGT_PROJECT_PATH/$category
        if [ "$default" == "\*" ]; then
            ### Remove previous default category
            sed -i 's/\*//g' $MGT_CONF_PATH/categories
        fi
        echo "$category:$label:$default" >> $MGT_CONF_PATH/categories
        $GIT add $MGT_CONF_PATH/categories
        $GIT commit -s -m "category: Add $category"
        ;;

    rm)
        shift
        sed -i "/$1/d" $MGT_CONF_PATH/categories
        $GIT add $MGT_CONF_PATH/categories
        $GIT commit -s -m "category: Remove $category"
        ;;

    --help|-h)
        usage_category
        exit 0
        ;;
    *)
        usage_category
        exit 1
        ;;
esac

exit 0

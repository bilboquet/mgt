#!/bin/bash
# Manage the known users
#

if [ -e ~/.mgtconfig ]; then
    . ~/.mgtconfig
else
    mgt -h
fi

usage_tag() {
    echo "usage: mgt tag list"
    echo "       mgt tag add -n <login> -e <email> -u <tagname>"
    echo "       mgt tag rm <tag>"
    echo "       mgt tag <-h|--help>"
}

usage_tag_add() {
    echo "usage: mgt tag add <options>"
    echo "  Options:"
    echo "    -T,--tag            Tag identifier to add"
    echo "    -l,--label          Tag label"
}

usage_tag_mv() {
    echo "usage: mgt tag mv <options>"
    echo "  Options:"
    echo "    -T,--tag            Tag to remove"
}

usage_tag_list() {
    echo "usage: mgt tag list"
}

if [ -z "$1" ]; then
    usage
fi

case "$1" in
    list)
        echo "tag:label"
        echo "---------"
        cat $MGT_CONF_PATH/tags
        ;;

    add)
        shift # Consume 'create'
        argv=$(getopt -o n:u:e: -l name:,tagname:,email: -- "$@")
        eval set -- "$argv"
        while true; do
            case "$argv" in
                -T|--tag)
                    tag="$2"
                    ;;
                -l|--label)
                    label="$2"
                    ;;
                --)
                    shift
                    break;
                    ;;
                *)
                    usage_tag_add
                    exit 1
            esac
        done

        echo "$tag:$label" >> $MGT_CONF_PATH/tags
        $GIT add $MGT_CONF_PATH/tags
        $GIT commit -s -m "tags: Add $tag"
        ;;

    rm)
        shift
        argv=$(getopt -o n: -l name: -- "$@")
        eval set -- "$argv"
        while true; do
            case "$argv" in
                -T|--tag)
                    name="$2"
                    ;;
                --)
                    shift
                    break
                    ;;
                *)
                    usage_tag_mv
                    exit 1
            esac
        done

        sed -i "/$1:/d" $MGT_CONF_PATH/tags
        $GIT add $MGT_CONF_PATH/tags
        $GIT commit -s -m "tags: Remove $tag"
        ;;

    --help|-h)
        usage_tag
        exit 0
        ;;

    *)
        usage_tag
        exit 1
        ;;
esac

exit 0

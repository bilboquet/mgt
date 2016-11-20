#!/bin/bash

if [[ -e ~/.mgtconfig ]]; then
    . ~/.mgtconfig
else
    mgt -h
fi

if [[ -z "$1" ]]; then
    usage_comment
fi

usage_comment () {
    echo "usage: mgt comment add --on <task|comment> --id <object_id> --message  \"comment title\""
    echo "       mgt comment edit"
    echo "       mgt comment show --id <object_id> --mode <(i)nteractive|(r)ecursive|(u)nique>"
    echo "       mgt comment <-h|--help>"
}

error () {
    usage_comment
    echo "Error: $1."
    exit 1
}

mgt_comment_add () {
#    set -x
    argv=$(getopt -o o:i:m: -l on:,id:,message: -- "$@")
    eval set -- "$argv"

    while [ true ]; do
        case "$1" in
            -o|--on)
                on="$2"
                ;;
            -i|--id)
                id="$2"
                ;;
            -m|--message)
                message="$2"
                ;;
            --)
                break
                ;;
            *)
                usage_comment
                exit 1
                ;;
        esac
        shift 2
    done

    ### TODO : check id exists

    [[ $on =~ ^(task|comment)$ ]] || error "--on <task|comment>" 

    found=$(find "$MGT_PROJECT_PATH/" -name $id -print -quit)
    [[ -n $found ]] || error "id $id does not exist"

    [[ -z "$message" ]] && error "Missing message"

    comment_id=$(uuidgen -t)
    [[ -z $comment_id ]] && error "getting uuid, check that uuidgen is in your PATH."

    mkdir -p "$MGT_PROJECT_PATH/comments/${id}_d"
    echo "Title: $message" > "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
#    echo "" >> "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    echo "" >> "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    echo "Author: $(git config user.name) <$(git config user.email)>" >> "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    echo "Date: $(date '+%F %T')" >> "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    echo "Body:" >> "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    echo "" >> "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    $EDITOR "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    $GIT add "$MGT_PROJECT_PATH/comments/${id}_d/$comment_id"
    $GIT commit -s -m "$(cat $MGT_CONF_PATH/project): comment: $id" -m "$(echo "$message" | head -n1)"
    echo "Comment on '$on' "$id" added successfully"

}

mgt_comment_show_helper () {
#    set -x
    local action
    for comment in $MGT_PROJECT_PATH/comments/${1}_d/*; do
        action=''
        eval printf '\\t%.0s' {1..$2}
        echo $(basename $comment)
        input="$comment"
#        set -x
        while IFS= read -r var; do
            # see http://wiki.bash-hackers.org/commands/builtin/printf for the FORMAT and {x..y} sequence exp
            eval printf '\\t%.0s' {1..$2}
            printf "$var\n"
        done < "$input"
        
        if [[ $3 == "interactive" ]]; then
            echo
            while true; do
                echo "(n)ext (d)escend (r)eply (q)uit"
                read -s -n 1 action
                case "$action" in
                    n|d|r|q)
                        break
                        ;;
                    *)
                        ;;
                esac
            done
        fi
        [[ "$action" == "q" ]] && exit 0
        id=$(basename $comment)
        [[ "$action" == "r" ]] && mgt_comment_add -o "comment" -i "$id" -m "Reply"
        [[ "$action" == "n" ]] && continue
        [[ ($3 == "recursive" || "$action" == "d") && -d "$MGT_PROJECT_PATH/comments/${id}_d" ]] && mgt_comment_show_helper "$id" $(($2+1)) $3
        set +x
    done
}

mgt_comment_show () {
#    set -x
    argv=$(getopt -o i:m: -l id:,mode: -- "$@")
    eval set -- "$argv"

    while [ true ]; do
        case "$1" in
            -i|--id)
                id="$2"
                ;;
            -m|--mode)
                mode="$2"
                ;;
            --)
                break
                ;;
            *)
                usage_comment
                exit 1
                ;;
        esac
        shift 2
    done
#    echo $mode
    case $mode in
        i|interactive)
            mode="interactive"
            ;;
        r|recursive)
            mode=recursive
            ;;
        u|unique)
            mode="unique"
            ;;
        *)
            error "Wrong mode"
            ;;
    esac

    [[ -d "$MGT_PROJECT_PATH/comments/${id}_d" ]] || { echo "No comment for $id."; exit 0; }
    mgt_comment_show_helper $id 1 "$mode"
    exit 0
}

case $1 in
    --help|-h)
        usage_comment
        exit 0
        ;;
    add)
        shift
        mgt_comment_add "$@"
        ;;
    edit)
        shift
        ### TODO:
        ;;
    show)
        shift
        mgt_comment_show "$@"
        ;;
    *)
        usage_comment
        exit 1
        ;;
esac

exit 0

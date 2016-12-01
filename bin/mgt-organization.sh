#!/bin/bash

if [ -e ~/.mgtconfig ]; then
    . ~/.mgtconfig
else
    mgt -h
fi

mgt_organization_usage () {
    echo "usage: mgt organization list"
    echo "       mgt organization select -n <name>"
    echo "       mgt organization remame <tag>"
    echo "       mgt organization <-h|--help>"
}

error () {
    mgt_organization_usage
    echo "Error: $1."
    exit 1
}

mgt_organization_list () {
    echo "Current organization: $(basename $MGT_PATH)"
    echo
    echo "Available organization(s):"
    
    for d in "$MGT_PATH"/../*; do 
        [[ -d $d && ! -h $d ]] && echo $(basename $d)
    done
    
    exit 0
}

mgt_organization_select () {
    [[ -z "$1" ]] && error "organization_name cannot be empty."
    org="$1"
    
    [[ -d "$MGT_PATH/../$org" ]] || error "organization \"$org\" does not exist."
    
    sed -i -e "s|MGT_ORG=.*|MGT_ORG=\"$org\"|" ~/.mgtconfig
    
    echo "organization \"$org\" selected."
    exit 0
}

# TODO
mgt_organization_rename () {
    return 0
}

case "$1" in
    list)
        mgt_organization_list
        ;;
    select)
        shift
        mgt_organization_select "$@"
        ;;
    rename)
        shift
        mgt_organization_remame "$@"
        ;;
    *)
        mgt_organization_usage
        exit 1
        ;;
esac
#!/bin/bash
#set -x
PATH=$PATH:$(dirname $0)

usage_mgt () {
    echo "usage: mgt init <-h|--help> -o|--organization <organization name> | -n|--new -r|--remote <remote> [--force]"
    echo "       mgt project <-h|--help|init|list|select|sync> ..."
    echo "       mgt task <-h|--help|create|move|edit||comment|tag|rm|filter> ..."
    echo "       mgt category <-h|--help|create|edit|rm|filter> ..."
    echo "       mgt config <-h|--help|-l|--list|set|get> ..."
    echo "       mgt organization <-h|--help|list|select|add|rename> ..."
}

if [ -z "$EDITOR" ]; then
    echo "Please set default editor using EDITOR environement variable: use 'vim' by default"
    export EDITOR=vim
fi

case "$1" in
    init)
        shift # consume init

        new=n
        force=n

        argv=$(getopt -o r:no: -l remote:,new,force,organization: -- "$@")
        eval set -- "$argv"
        while [ true ]; do
            case "$1" in
                -r|--remote)
                    remote="$2"
                    shift #consume param remote
                    ;;

                --force)
                    force=-f
                    ;;

                -n|--new)
                    new=y
                    ;;
                -o|--organization)
                    org="$2"
                    shift
                    ;;
                --)
                    shift
                    break
                    ;;

                *)
                    usage_init
                    exit 1
                    ;;
            esac
            shift #next arg
        done
        
        [[ -z "$org" ]] && org="default"

        if [[ ! -e ~/.mgtconfig ]]; then
            echo 'Creating ~/.mgtconfig'
            echo '### Do not modify' > ~/.mgtconfig
            echo '### Variables' >> ~/.mgtconfig
            echo "MGT_ORG=\"$org\"" >> ~/.mgtconfig
            echo 'MGT_PATH=~/.mgt/$MGT_ORG' >> ~/.mgtconfig
            echo 'MGT_CONF_PATH=$MGT_PATH/conf.d' >> ~/.mgtconfig
            echo 'MGT_PROJECT_PATH=$MGT_PATH/project' >> ~/.mgtconfig
            echo '### Commands' >> ~/.mgtconfig
            echo 'GIT="git --work-tree=$MGT_PATH --git-dir=$MGT_PATH/.git"' >> ~/.mgtconfig
        fi
        
        [[ "$org" != "default" ]] && sed -i -e "s|MGT_ORG=.*|MGT_ORG=\"$org\"|" ~/.mgtconfig

        . ~/.mgtconfig

        [[ -d "$MGT_PATH" ]] && error "organization \"$MGT_ORG\" already exists."

        mkdir -p "$MGT_PATH"
        # Create work dirs
        mkdir -p "$MGT_PATH/conf.d"
        mkdir -p "$MGT_PATH/project"
#        mkdir -p "$MGT_PATH/.git"

        echo "organization \"$MGT_ORG\" created."


        if [ "$new" == "y" ]; then
            echo "mgt repository" > $MGT_PATH/README

            $GIT init
            echo "mgt: project management" > $MGT_PATH/.git/description
            $GIT add .
            $GIT commit -s -m "Project: create project management repository"
            if [ ! -z "$remote" ]; then
                if [ ! "$force" == "-f" ]; then
                    echo -n "You use --new combined with --remote without "
                    echo -n "--force. <remote> won't be overwritten which "
                    echo "is safe but may result in an error."
                    unset force #if $force != '-f' then force has to be empty
                fi
                $GIT remote remove origin
                $GIT remote add origin $remote
                $GIT push $force origin master
            fi
        else
            if [ ! -z "$remote" ]; then
                git clone $remote $MGT_PATH
            else
                echo " *** You specified a not new remote: --remote is then mandatory..."
                echo ""
                usage_mgt
                exit 1
            fi
        fi
        ;;

    project)
        shift
        mgt-project.sh "$@"
	    ;;

    task)
        shift
        mgt-task.sh "$@"
	    ;;

    category)
        shift
        mgt-category.sh "$@"
	    ;;

    user)
        shift
        mgt-user.sh "$@"
        ;;

    tag)
        shift
        mgt-tag.sh "$@"
        ;;
    
    config)
        shift
        mgt-config.sh "$@"
        ;;
    comment)
       shift
       mgt-comment.sh "$@"
       ;;
    organization)
        shift
        mgt-organization.sh "$@"
        ;;
    -h|--help)
        usage
        ;;

    *)
        usage_mgt
        exit 1
        ;;
esac

exit $?

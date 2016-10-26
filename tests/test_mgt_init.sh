#!/bin/bash
#set -x
export PATH=$PATH:"$(dirname $0)/../bin"

if [ ! -e ~/.mgtconfig ]; then
    mgt init --new
fi

sed -i -e 's#MGT_PATH=~/.mgt.*#MGT_PATH=~/.mgt-test#' ~/.mgtconfig
. ~/.mgtconfig



do_test () {
    if [ "$1" == "-i" ]; then
        shift
        interactive=true
    fi
    
    echo -n "##### $1"
    if [ $# -eq 1 ]; then
        echo
        if [ ! interactve ]; then
            $($1)
        else
            $1
        fi
    else
        echo $2
        if [ ! interactve ]; then
            $($1 <<< "$2")
        else
            $1 <<< "$2"
        fi
    fi
    echo
}



echo "##################################################"
echo "#### Warning, this test will remove $MGT_PATH ####"
echo "##################################################"
echo "Press enter to continue or C^c to quit"
read

do_test "rm -rf $MGT_PATH"
rm -rf $MGT_PATH

do_test "mgt init -r https://github.com/bilboquet/test.git"

do_test "rm -rf $MGT_PATH"
rm -rf $MGT_PATH

do_test "mgt init"

do_test "mgt init --new"

do_test "rm -rf $MGT_PATH"
rm -rf $MGT_PATH

do_test "mgt init --new -r https://github.com/bilboquet/test.git"

do_test "rm -rf $MGT_PATH"
rm -rf $MGT_PATH

do_test "mgt init -n -r https://github.com/bilboquet/test.git --force"

do_test "mgt project init"

do_test "mgt project init test_proj1"

do_test "mgt project init test_proj1"

do_test "mgt project init test_proj2"

do_test "mgt project list"

do_test "mgt task list"

do_test "mgt task create"

do_test "mgt task create -c todo"

do_test "-i" "mgt task create -c todo -d description"

do_test "mgt task list"

seq=$'s\nh\na\nh\nq'
do_test "mgt task list -i" "$seq"

do_test "mgt task list -f Assignee=Jean"

do_test "mgt project sync"

do_test "mgt project select test_proj1"

do_test "mgt task create -c todo -d description"

do_test "mgt project sync"


### end of tests
sed -i -e 's#MGT_PATH=~/.mgt-test.*#MGT_PATH=~/.mgt#' ~/.mgtconfig

#!/bin/bash
#set -x
export PATH=$PATH:"$(dirname $0)/../bin"

if [ ! -e ~/.mgtconfig ]; then
    mgt init --new
fi

sed -i -e 's#MGT_PATH=~/.mgt.*#MGT_PATH=~/.mgt-test#' ~/.mgtconfig
. ~/.mgtconfig

do_test () {
    echo -n "##### $1"
    if [ $# -eq 1 ]; then
        echo
        $1
    else
        echo $2
        $1 <<< "$2"
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

do_test "mgt project init"

do_test "mgt project init test_proj1"

do_test "mgt project init test_proj1"

do_test "mgt project init test_proj2"

do_test "mgt project list"

do_test "mgt task list"

do_test "mgt task create"

do_test "mgt task create -c todo"

do_test "mgt task create -c todo -d description"

do_test "mgt task list"

seq=$'s\nh\na\nh\nq'
do_test "mgt task list -i" "$seq"

do_test "mgt task list -f Assignee=Jean"




sed -i -e 's#MGT_PATH=~/.mgt-test.*#MGT_PATH=~/.mgt#' ~/.mgtconfig

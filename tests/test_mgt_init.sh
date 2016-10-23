#!/bin/bash
#set -x
PATH=$PATH:$(dirname $0)/../bin

do_test () {
    echo "##### $1"
    if [ $# -eq 1 ]; then
        $1
    else
        $1 <<< "$2"
    fi
    echo
}

echo "###############################################"
echo "#### Warning, this test will corrupt ~/.mgt ####"
echo "###############################################"
echo "Press enter to continue"
read

do_test "rm -rf ~/.mgt"
rm -rf ~/.mgt

do_test "mgt init -r https://github.com/bilboquet/test.git"

do_test "rm -rf ~/.mgt"
rm -rf ~/.mgt

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

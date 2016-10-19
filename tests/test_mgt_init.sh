#!/bin/bash
#set -x
PATH=$PATH:$(dirname $0)/../bin

do_test () {
    echo "##### $1"
    $1
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


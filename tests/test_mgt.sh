#!/bin/bash
#set -x
export PATH=$PATH:"$(dirname $0)/../bin"

if [ ! -e ~/.mgtconfig ]; then
    mgt init --new
fi

# test setup
rm -rf /tmp/test.git && pushd . && mkdir -p /tmp/test.git && cd /tmp/test.git && git init --bare && popd
sed -i -e 's#MGT_PATH=~/.mgt.*#MGT_PATH=/tmp/mgt-test#' ~/.mgtconfig
. ~/.mgtconfig

REMOTE=/tmp/test.git


# check_res "test_name" "expected result" "result" "command output"
function check_res () {
    mkdir -p "$1"
    echo "$4" > "$1/out"
    
#    diff -q "$1".out "$1".out.ref
    check="0"
    if [ -x "$1/check_test" ]; then
        cmd="$1/check_test > /dev/null 2>&1 "
        eval $cmd
        check=$?
    fi
    
    if { [ "$check" != "0" ]; } ||
       { [ "$2" == "ok" ] && [ ! "$3" == "0" ]; } ||
       { [ "$2" == "nok" ] && [ "$3" == "0" ]; } ; then
        # ERROR

        while [ true ]; do
            echo ">> ERROR running test \"$1\""
            echo "received $3, $2 was awaited"
            echo "check:$check"
            echo "show (o)utput, show (d)iff, (r)un check, (u)pdate ref, (n)ext, (q)uit"
            read input
            case $input in
                o)
                    cat "$1/out"
                    ;;
                d)
                    diff "$1/out" "$1/out.ref"
                    ;;
                u)
                    cp "$1/out" "$1/out.ref"
                    ;;
                ""|n|next)
                    break
                    ;;
                r)
                    "$1/check_test"
                    ;;
                q)
                    exit 0
                    ;;
                *)
                    ;;
            esac
        done

    else
        echo "test \"$1\" ok"
    fi
}

#do_test [-i] "test_name" "expected result: ok|nok" "test command" ["command sequence"]
function do_test () {
    interactive=''
    if [ "$1" == "-i" ]; then
        shift
        interactive=true
    fi
    test_name="$1"
    shift
    exp_res="$1"
    shift
            
    echo -n "##### test $test_name : '$1'"
    if [ $# -eq 1 ]; then
        echo
        if [ ! $interactive ]; then
            cmd="$1 2>&1"
            eval test_out=\$\($cmd\)
            check_res "$test_name" "$exp_res" "$?" "$test_out"
        else
            eval "$1"
        fi
    else
        echo $2
        if [ ! $interactive ]; then
            ### TODO: as above use eval to prevent param spliting
            test_out=$($1 <<< "$2" 2>&1)
            check_res "$test_name" "$exp_res" "$?" "$test_out"
        else
            eval $1 <<< "$2"
        fi
    fi
    echo
}



echo "##################################################"
echo "#### Warning, this test will remove $MGT_PATH ####"
echo "##################################################"
echo "Press enter to continue or C^c to quit"
#if false; then # jump to #end jump
#read

rm -rf $MGT_PATH
do_test "1" "ok" "mgt init -r $REMOTE"

rm -rf $MGT_PATH
do_test "2" "nok" "mgt init"

do_test "3" "ok" "mgt init --new"

rm -rf $MGT_PATH
do_test "4" "ok" "mgt init --new -r $REMOTE"

rm -rf $MGT_PATH
do_test "5" "ok" "mgt init -n -r $REMOTE --force"

do_test "6" "nok" "mgt project init"

do_test "7" "ok" "mgt project init test_proj1"

do_test "7.1" "nok" "mgt project init test_proj1"

do_test "7.2" "ok" "mgt project init test_proj2"

do_test "8" "ok" "mgt project list"

#do_test "9" "ok" "mgt task search"
#
#do_test "9.1" "nok" "mgt task add"
#
#do_test "9.2" "nok" "mgt task add -c todo"

seq=$'\030' #Send ^X to nano editor so it closes 
do_test "9.3" "ok" "mgt task add -c todo -d description" "$seq"

#do_test "9.4" "ok" "mgt task search"
#
#seq=$'s\nh\na\nh\nq'
#do_test "9.5" "ok" "mgt task search -i" "$seq"
#
#do_test "9.6" "ok" "mgt task search -f Assignee=Jean"

do_test "9.7" "ok" "mgt project sync"

do_test "9.8" "ok" "mgt project select test_proj1"

seq=$'\030'
do_test "9.9" "ok" "mgt task add -c todo -d description" "$seq"

do_test "9.10" "ok" "mgt project sync"

seq=$'\030'
do_test "9.11" "ok" "mgt task add -c todo -d description" "$seq"

do_test "9.12" "ok" "mgt task depends -c todo -t 1 -o 2"

seq=$'\030'
do_test "9.13" "ok" "mgt task add -c todo -d description"  "$seq"
#fi #end jump
do_test "9.14" "ok" "mgt task depends -c todo -t 1 -o 2,3"

seq=$'\030'
do_test "9.15" "ok" "mgt task add -c todo -d description" "$seq"

do_test "9.16" "ok" "mgt task depends -c todo -t 1 -o 4 -o 2,3"

do_test "9.17" "ok" "mgt task depends -c todo -t 1 -o 3 --ndep \"2,4\""

do_test "9.18" "nok" "mgt task depends -c todo -t 1 -o 6 --ndep \"2,3,4\""


#### end of tests
rm -rf /tmp/test.git /tmp/mgt-test
#sed -i -e 's#MGT_PATH=/tmp/mgt-test.*#MGT_PATH=~/.mgt#' ~/.mgtconfig

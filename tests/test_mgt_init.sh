#!/bin/bash
#set -x
export PATH=$PATH:"$(dirname $0)/../bin"

if [ ! -e ~/.mgtconfig ]; then
    mgt init --new
fi

sed -i -e 's#MGT_PATH=~/.mgt.*#MGT_PATH=~/.mgt-test#' ~/.mgtconfig
. ~/.mgtconfig

# check_res "test_name" "expected result" "result" "command output"
check_res () {
    echo "$4" > "$1".out
    
#    diff -q "$1".out "$1".out.ref
    
    if { [ "$2" == "ok" ] && [ ! "$3" == "0" ]; } ||
       { [ "$2" == "nok" ] && [ "$3" == "0" ]; } ; then
        # ERROR

        while [ true ]; do
            echo ">> ERROR running test \"$1\""
            echo "received $3 while $2 was awaited"
            echo "sh(o)w output, (s)how diff, (u)pdate ref, (n)ext"
            read input
            case $input in
                o)
                    cat "$1".out
                    ;;
                s|show)
                    diff "$1".out "$1".out.ref
                    ;;
                u)
                    cp "$1".out "$1".out.ref
                    ;;
                ""|n|next)
                    break
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
do_test () {
    interactive=''
    if [ "$1" == "-i" ]; then
        shift
        interactive=true
    fi
    test_name="$1"
    shift
    exp_res="$1"
    shift
    
    echo -n "##### test $test_name : $1"
    if [ $# -eq 1 ]; then
        echo
        if [ ! $interactive ]; then
            test_out=$($1 2>&1)
            check_res "$test_name" "$exp_res" "$?" "$test_out"
        else
            $1
        fi
    else
        echo $2
        if [ ! $interactive ]; then
            test_out=$($1 <<< "$2" 2>&1)
            check_res "$test_name" "$exp_res" "$?" "$test_out"
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

#rm -rf $MGT_PATH
#do_test "1" "ok" "mgt init -r https://github.com/bilboquet/test.git"
#
#rm -rf $MGT_PATH
#do_test "2" "nok" "mgt init"
#
#do_test "3" "ok" "mgt init --new"
#
#rm -rf $MGT_PATH
#do_test "4" "ok" "mgt init --new -r https://github.com/bilboquet/test.git"

rm -rf $MGT_PATH
do_test "5" "ok" "mgt init -n -r https://github.com/bilboquet/test.git --force"

do_test "6" "nok" "mgt project init"

do_test "7" "ok" "mgt project init test_proj1"

do_test "7.1" "nok" "mgt project init test_proj1"

do_test "7.2" "ok" "mgt project init test_proj2"

do_test "8" "ok" "mgt project list"

do_test "9" "ok" "mgt task search"

do_test "9.1" "nok" "mgt task add"

do_test "9.2" "nok" "mgt task add -c todo"

do_test "-i" "9.3" "ok" "mgt task add -c todo -d description"

do_test "9.4" "ok" "mgt task search"

seq=$'s\nh\na\nh\nq'
do_test "9.5" "ok" "mgt task search -i" "$seq"

do_test "9.6" "ok" "mgt task search -f Assignee=Jean"
#sync needs to be fixed !
#do_test "9.7" "ok" "mgt project sync"

do_test "9.8" "ok" "mgt project select test_proj1"

do_test "-i" "9.9" "ok" "mgt task add -c todo -d description"

#do_test "9.10" "ok" "mgt project sync"

do_test "-i" "9.11" "ok" "mgt task add -c todo -d description"

do_test "9.12" "ok" "mgt task depends -c todo -t 1 -o 2"

#### end of tests
#sed -i -e 's#MGT_PATH=~/.mgt-test.*#MGT_PATH=~/.mgt#' ~/.mgtconfig

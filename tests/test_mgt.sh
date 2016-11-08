#!/bin/bash
#set -x
export PATH=$PATH:"$(dirname $0)/../bin"

if [ ! -e ~/.mgtconfig ]; then
    mgt init --new
fi

REMOTE=/tmp/test.git

# test setup
rm -rf "$REMOTE" && pushd . && mkdir -p "$REMOTE" && cd "$REMOTE" && git init --bare && popd
sed -i -e 's#MGT_PATH=~/.mgt.*#MGT_PATH=/tmp/mgt-test#' ~/.mgtconfig
. ~/.mgtconfig


# check_res "test_name" "result"
function check_res () {
    exp_res=$(cat exp_res 2>&1) || { echo "Error: can't find expected result for test $test_name" ; return 1; }
    [[ $exp_res == "ok" || $exp_res == "nok" ]] || { echo "Error: invalid expected result $exp_res for test:$test_name" ; return 1; }
     

    diff_res="0"
    [[ -e out.ref ]] && { diff -q out out.ref; diff_res=$?; }
    
    check="0"
    if [ -x "check_test" ]; then
        cmd="./check_test > /dev/null 2>&1 "
        eval $cmd
        check=$?
    fi
    
    if { [ "$diff_res" != "0" ]; } ||
       { [ "$check" != "0" ]; } ||
       { [ "$exp_res" == "ok" ] && [ ! "$2" == "0" ]; } ||
       { [ "$exp_res" == "nok" ] && [ "$2" == "0" ]; } ; then
        # ERROR

        while [ true ]; do
            echo ">> ERROR running test \"$1\""
            echo "received $2, $exp_res was awaited"
            echo "check:$check diff:$diff_res"
            echo "show (o)utput, show (d)iff, (r)un check, (u)pdate ref, (n)ext, (q)uit"
            read input
            case $input in
                o)
                    cat out
                    ;;
                d)
                    diff "out" "out.ref"
                    ;;
                u)
                    cp "out" "out.ref"
                    ;;
                ""|n|next)
                    break
                    ;;
                r)
                    "./check_test"
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

# do_test "test_name"
function do_test () {
    test_name="$1"
    echo -n "# test $test_name"
    cd "$test_name" || { echo "\nError: can't find test:$test_name" ; return 1; }

    # call the setup fonction of the script
    ./test_script.sh "setup" || { echo "Error no setup for test:$test_name" ; return 1; }
    # if test defines a pretty name, print it, else newlane 
    [[ -e pretty_name ]] && { echo -n ": "; cat pretty_name; } || echo

    # run the test
    unset input interactive
    [[ -e input ]] && input=" < input"
    interactive=" 2>&1 | tee out"
    [[ ! -e interactive ]] && interactive=" > out 2>&1"
    # Because tee will always return 0, we use pipefail to get the test status
    set -o pipefail
    eval ./test_script.sh $input $interactive
    test_res="$?"
    check_res "$test_name" "$test_res" 
    return $?
}



echo "##################################################"
echo "#### Warning, this test will modify $MGT_PATH ####"
echo "##################################################"
echo "Press enter to continue or C^c to quit"
#if false; then # jump to #end jump
read
echo
echo

# find tests
# find dirs containing a test, print the dirname (i.e. the test name|number), remove leading './'
# then sort => tests 
[[ "$1" == "all" || $# -eq 0 ]] && tests=$(find . -name 'test_script.sh' -printf "%h\n" | sed -e 's|^./||' | sort | xargs)
[[ $# -ge 1 ]] && tests=$@

# check we are in tests dir
tests_dir=$(pwd)
[[ $tests_dir =~ .*/tests ]] || exit 1

echo "Will run test(s): $tests"
for t in $tests; do
    [[ ! -z $FORCE_INTERACTIVE ]] && { read; clear; touch "$t/interactive"; }
    do_test "$t"
    cd "$tests_dir"
done

exit 0

#### end of tests
rm -rf /tmp/test.git /tmp/mgt-test
sed -i -e 's#MGT_PATH=/tmp/mgt-test.*#MGT_PATH=~/.mgt#' ~/.mgtconfig

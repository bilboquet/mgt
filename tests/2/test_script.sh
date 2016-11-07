#!/bin/bash

. ../config_test
function setup () {
    echo "mgt init" > pretty_name
    # expected result of the test
    echo "nok" > exp_res
    
    # if interactive test uncomment folling line
    # touch interactive
    
    # put input of the test, if any, into input: echo "values" > input

    exit 0
}
[[ "$1" == "setup" ]] && setup

rm -rf "$MGT_PATH"
mgt init

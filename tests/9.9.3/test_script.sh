#!/bin/bash

. ../config_test
function setup () {

    # expected result of the test
    echo "ok" > exp_res
    
    # if interactive test uncomment folling line
    # touch interactive
    
    # put input of the test, if any, into input: echo "values" > input

    exit 0
}
[[ "$1" == "setup" ]] && setup

tasks=( $(ls "$MGT_PROJECT_PATH/todo/" | sort) )

mgt task depends -c todo -t ${tasks[0]} -o ${tasks[1]}

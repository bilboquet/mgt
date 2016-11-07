#!/bin/bash

. ../config_test
function setup () {

# expected result of the test
echo "nok" > exp_res

# if interactive test uncomment folling line
# touch interactive

# put input of the test, if any, into input: echo "values" > input

    exit 0
}
[[ "$1" == "setup" ]] && setup

mgt task depends -c todo -t 1 -o 6 --ndep "2,3,4"

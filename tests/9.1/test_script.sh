#!/bin/bash

. ../config_test

# expected result of the test
echo "nok" > exp_res

# if interactive test uncomment folling line
# touch interactive

# put input of the test, if any, into input: echo "values" > input

mgt task add

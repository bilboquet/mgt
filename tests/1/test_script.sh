#!/bin/bash

. ../config_test

# expected result of the test
echo "ok" > exp_res

# if interactive test uncomment folling line
# touch interactive

# put input of the test, if any, into input: echo "values" > input

rm -rf "$MGT_PATH"
mgt init -r "$REMOTE"

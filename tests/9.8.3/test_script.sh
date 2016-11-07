#!/bin/bash

. ../config_test

# expected result of the test
echo "ok" > exp_res

# if interactive test uncomment folling line
# touch interactive

# put input of the test, if any, into input: echo "values" > input
#seq=$'\030' #Send ^X to nano editor so it closes 
echo "" > input

mgt task add -c todo -d description

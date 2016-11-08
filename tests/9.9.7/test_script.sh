#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task depends -c todo -t fist -o fouth -o second,third (multiple dep)"


[[ "$1" == "setup" ]] && setup

tasks=( $(ls "$MGT_PROJECT_PATH/todo/" | sort) )

mgt task depends -c todo -t ${tasks[0]} -o ${tasks[3]} -o ${tasks[1]},${tasks[2]}

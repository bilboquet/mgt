#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task depends -c todo -t fist -o second"


[[ "$1" == "setup" ]] && setup

tasks=( $(ls "$MGT_PROJECT_PATH/todo/" | sort) )

mgt task depends -c todo -t ${tasks[0]} -o ${tasks[1]}

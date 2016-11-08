#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt init -n -r "$REMOTE" --force"


[[ "$1" == "setup" ]] && setup

rm -rf "$MGT_PATH"
mgt init -n -r "$REMOTE" --force

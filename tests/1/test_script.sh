#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt init -r $REMOTE"

# Interactive test
#INTERACTIVE=true

# Inputs of the test
#INPUTS="a b c"


[[ "$1" == "setup" ]] && setup

rm -rf "$MGT_PATH"
mgt init -r "$REMOTE"

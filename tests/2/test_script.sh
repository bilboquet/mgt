#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="nok"

# Test name that will be displayed before running
PRETTY_NAME="mgt init (missing arg)"


[[ "$1" == "setup" ]] && setup

rm -rf "$MGT_PATH"
mgt init

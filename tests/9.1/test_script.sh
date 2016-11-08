#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="nok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task add (default category, missing description)"


[[ "$1" == "setup" ]] && setup

mgt task add

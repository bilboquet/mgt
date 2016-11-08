#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task search -f Assignee=Jean"


[[ "$1" == "setup" ]] && setup

mgt task search -f Assignee=Jean

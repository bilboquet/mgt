#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok|nok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task depends ??? unknown task ???"


[[ "$1" == "setup" ]] && setup

mgt task depends -c todo -t 1 -o 6 --ndep "2,3,4"

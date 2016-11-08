#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task add -c todo -d \"second task\""

# Automatically close the editor
[[ $EDITOR =~ .*nano.* ]] && INPUTS="^X"
[[ $EDITOR =~ .*vim.* ]] && INPUTS=":x"


[[ "$1" == "setup" ]] && setup

mgt task add -c todo -d "second task"

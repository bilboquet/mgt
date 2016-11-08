#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task search -i"

# Apply a sequence of commande in interactive search
INPUTS=$'s\nh\na\nh\nq'


[[ "$1" == "setup" ]] && setup

mgt task search -i

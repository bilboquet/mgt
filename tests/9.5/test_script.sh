#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task search -i"

# Apply a sequence of commande in interactive search
INPUTS=$'dhahq'


[[ "$1" == "setup" ]] && setup

cat > "check_test" << 'EOL'
#!/bin/bash
. ~/.mgtconfig
set -x

nb_task=$(ls "$MGT_PROJECT_PATH/todo" | wc -l)
[[ $nb_task -eq 1 ]] || exit 1 # wrong number of tasks
# get first task
first_task=$(ls "$MGT_PROJECT_PATH/todo" | head -n1)
# check that 1st task was "self assigned" during test
grep -e "Assignee: $(git config user.name) <$(git config user.email)>" "$MGT_PROJECT_PATH/todo/$first_task"
[[ $? -eq 0 ]] || exit 1 # task was not correctly assigned during test

exit 0
EOL

mgt task search -i

#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task add -c todo -d \"fourth task\""

# Automatically close the editor
[[ $EDITOR =~ .*nano.* ]] && INPUTS="^X"
[[ $EDITOR =~ .*vim.* ]] && INPUTS=":x"


[[ "$1" == "setup" ]] && setup

# check test result
cat > "check_test" << 'EOL'
#!/bin/bash
. ~/.mgtconfig
set -x

[ -d "$MGT_PROJECT_PATH" ] || exit 1
[ -d "$MGT_PROJECT_PATH/done" ] || exit 1
[ -d "$MGT_PROJECT_PATH/todo" ] || exit 1
[ "$(ls "$MGT_PROJECT_PATH/todo/" | wc -l)" == "3" ] || exit 1 # wrong number of tasks

exit 0
EOL


mgt task add -c todo -d "fourth task"

#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt task depends -c todo -t fist -o second,third"


[[ "$1" == "setup" ]] && setup


cat > "check_test" << 'EOL'
#!/bin/bash
. ~/.mgtconfig
set -x

tasks=( $(ls "$MGT_PROJECT_PATH/todo/" | sort) )

nb_task=$(ls "$MGT_PROJECT_PATH/todo" | wc -l)
[[ $nb_task -eq 4 ]] || exit 1 ; # wrong number of tasks
grep -E "Depends: +\b${tasks[1]}\b \b${tasks[2]}\b" "$MGT_PROJECT_PATH/todo/${tasks[0]}" || exit 1 ; # dep not added
exit 0
EOL

# Test
tasks=( $(ls "$MGT_PROJECT_PATH/todo/" | sort) )
mgt task depends -c todo -t ${tasks[0]} -o ${tasks[1]},${tasks[2]}

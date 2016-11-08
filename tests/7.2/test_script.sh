#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt project init test_proj2 (second project)"


[[ "$1" == "setup" ]] && setup

# check test result
cat > "check_test" << 'EOL'
#!/bin/bash
. ~/.mgtconfig
set -x

[ -d "$MGT_PROJECT_PATH" ] || exit 1
[ -d "$MGT_PROJECT_PATH/done" ] || exit 1
[ -d "$MGT_PROJECT_PATH/todo" ] || exit 1

exit 0
EOL


mgt project init test_proj2

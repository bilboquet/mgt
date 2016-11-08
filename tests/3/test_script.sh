#!/bin/bash

. ../config_test

# Expected result of the test
EXP_RES="ok"

# Test name that will be displayed before running
PRETTY_NAME="mgt init --new"


[[ "$1" == "setup" ]] && setup

# check test result
cat > "check_test" << 'EOL'
#!/bin/bash
. ~/.mgtconfig
set -x

[ -d "$MGT_PROJECT_PATH" ] || exit 1

exit 0
EOL


mgt init --new

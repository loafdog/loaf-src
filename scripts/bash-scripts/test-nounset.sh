#!/bin/bash

set -x
set -o nounset # -u

FOO="FOO"
#BAR="BAR"

echo "FOO=$FOO"
# this will fail when -u is set
#echo "BAR=$BAR"

# From:
# http://stackoverflow.com/questions/874389/bash-test-for-a-variable-unset-using-a-function

# test if a var is set or not when -u opt is set
if [ ! ${!BAR[@]} ]; then
    echo "FALSE test with {!BAR[@]}"
else
    echo "TRUE {!BAR[@]}"
    echo "BAR=$BAR"
fi

# if [ ${BAR-_} ]; then
#     echo "TRUE"
#     echo "BAR=$BAR"
# else
#     echo "FALSE"
# fi
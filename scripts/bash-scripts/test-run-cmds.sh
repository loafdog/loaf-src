#!/bin/bash -x

set -o pipefail

# This works fine. 
function works1()
{
    local device="$1"
    local cmd="/bin/dd if=$device bs=10 count=1 status=noxfer "
    res=$($cmd)
    echo "$res"
}
works1 "/dev/null"
#works1 "/dev/random"

# Try adding a pipe to output of dd to do a checksum.
function foo1()
{
    local device="$1"
    local cmd="/bin/dd if=$device bs=10 count=1 status=noxfer | sum"

    # none of these work.  BASH does some funky stuff with quotes and parameter expansion
    #
    #res=$($cmd) 
    #
    #res=$("$cmd")

    # but this works. see
    # http://stackoverflow.com/questions/6087494/bash-inserting-quotes-into-string-before-execution
    res=$(bash -c "$cmd")
    rc=$?
    echo "rc=$rc res=$res"

    # Ahh.. but since we invoke bash it doesn't inherit opt settings?
    # So we need to set pipefail again in the cmd to catch errors from
    # dd, like a bad input file
    res=$(bash -c "set -o pipefail; $cmd")
    rc=$?
    echo "rc=$rc res=$res"

}
foo1 "/dev/null"
foo1 "foobar"


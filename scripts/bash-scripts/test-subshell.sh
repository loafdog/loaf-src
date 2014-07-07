#!/bin/bash

PWD=$(readlink -f $(dirname $0))
echo "PWD $PWD"

test_func1() 
{
    ( foo || return 1 ) || return 2
    return 0
}

test_func2() 
{
    ( foo ) || return 2
    return 0
}

test_func3() 
{
    ( foo || return 1 )
    return 0
}


echo "in parent shell"
echo "BASH_SUBSHELL=$BASH_SUBSHELL"
echo "$=$$"
echo "PPID=$PPID"
echo

(
echo "in sub shell"
echo "BASH_SUBSHELL=$BASH_SUBSHELL"
echo "$=$$"
echo "PPID=$PPID"
echo
)
echo $?

test_func1
echo "test_func1 = $?"

test_func2
echo "test_func2 = $?"

test_func3
echo "test_func3 = $?"
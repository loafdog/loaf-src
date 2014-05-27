#!/bin/bash

function return_val()
{
    if [[ $1 -eq 1 ]]; then
        return 1
    fi
    return 0
}

function test1()
{
    local rc
    return_val "0" || { rc=$?; }
    rc=$?
    echo "rc=$rc"
}

function test2()
{
    local rc
    return_val "1" || { rc=$?; }
    rc=$?
    echo "rc=$rc"
}

function test3()
{
    local rc
    rc=0
    return_val "1" || { rc=$?; }

    echo "rc=$rc"
}

test1
test2
test3
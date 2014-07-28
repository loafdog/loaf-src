#!/bin/bash

# test out arithmetic operations.

function foo()
{
    local i=0
    local j=0
    j=$((i+=1))
    echo "foo: i=$i j=$j"
    j=$((i+1))
    echo "foo: i=$i j=$j"
    j=$((i-1))
    echo "foo: i=$i j=$j"
    (( j+=1 ))
    echo "foo: i=$i j=$j"
}

function bar()
{
    local i=0
    local j=$((i+=1))
    echo "bar: i=$i j=$j"
}

function arithmetic_exits_with_error()
{
# if -e is set lines like var=$((1+1)) will fail if the arithmetic
# evals to 0

    local i=1
    echo "exit_with_error: i=$i"
    ((i-=1)) || true
    echo "exit_with_error: i=$i"


}

bar
foo
arithmetic_exits_with_error
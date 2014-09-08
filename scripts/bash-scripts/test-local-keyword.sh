#!/bin/bash

function foo()
{
    local rc=$(/bin/foo)
    return $rc
}

function bar()
{
    local rc
    rc=$(/bin/foo)
    return $rc
}

foo
echo "foo rc=$?"
bar
echo "bar rc=$?"
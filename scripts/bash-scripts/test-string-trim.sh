#!/bin/bash

function test_trim_both()
{
    # longest substring match from front. Deletes everything up to
    # last / in string
    local s=${1##*/}
    # long substring match from back. Deletes '__done' from end of str
    s=${s%%__done}
    echo "[$1]->[$s]"
}

function test_trim_front_long()
{
    local s=${1##*/}
    echo "front long: [$1]->[$s]"
}

function test_trim_front_short()
{
    local s=${1#*/}
    echo "front short: [$1]->[$s]"
}

function test_trim_back_long()
{
    local s=${1%%/*}
    echo "back long: [$1]->[$s]"
}

function test_trim_back_short()
{
    local s=${1%/*}
    echo "back short:  [$1]->[$s]"
}

str="/genesis/progress/4-2/hyper-4-2-10__done"

test_trim_both $str
echo
test_trim_front_short $str
test_trim_back_short $str
echo
test_trim_front_long $str
test_trim_back_long $str

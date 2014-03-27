#!/bin/bash

function test_trim_both()
{
    # longest substring match from front. Deletes everything up to
    # last / in string
    local s=${1##*/}
    # long substring match from back. Deletes '__done' from end of str
    s=${s%%__done}
    echo "$s"
}

str="/genesis/progress/4-2/hyper-4-2-10__done"
res=$(test_trim_both $str)
echo "$str -> $res"
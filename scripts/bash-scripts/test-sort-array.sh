#!/bin/bash


function test_sort()
{
    local unsorted=(5 4 3 2 1)
    local sorted=()
    sorted=$(echo ${unsorted[@]} | tr ' ' '\n' | sort)
    echo ${unsorted[@]}
    echo ${sorted[@]}

}

function test_sort2()
{
    local line="MULTI_CHASSIS_IDS=(5 4 3 2 1)"
    echo "$line"
    local arr=(${line//\=/ })
    echo "arr ${#arr[@]} [${arr[0]}] "
    if [ ${#arr[@]} -eq 1 ]; then
        echo "${arr[0]} is not set"
        err=1
        break
    else
        local sorted=$(echo "${arr[@]:1}" |  tr '()' ' ' | tr ' ' '\n' | sort)
        line="${arr[0]}=(${sorted[@]})"
        echo $line
    fi
}


test_sort

test_sort2
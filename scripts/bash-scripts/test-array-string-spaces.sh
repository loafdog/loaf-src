#!/bin/bash


function runtest()
{
    local str="busta"
    local -a cmds=(
        "$str foo bar"
        "$str whoo hah"
    )
    echo
    echo "without quoting array in for loop output is broken up by spaces"
    for cmd in ${cmds[@]}; do
        echo "Running [$cmd]"
    done
    
    echo
    echo "quoting array in for loop output is broken up by line"
    for cmd in "${cmds[@]}"; do
        echo "Running [$cmd]"
    done

}

runtest
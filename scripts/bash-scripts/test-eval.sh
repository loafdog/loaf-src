#!/bin/bash

function my_cmd_eval()
{
    if [[ $# -eq 0 ]]; then
        local my_args="foo"
    else
        local my_args="${@:1}"
    fi
    local my_cmd="echo $my_args"
    eval $my_cmd || return 1
    return 0
}

function my_cmd()
{
    if [[ $# -eq 0 ]]; then
        local my_args="foo"
    else
        local my_args="${@:1}"
    fi
    local my_cmd="echo $my_args"
    $my_cmd || return 1
    return 0
}

PWD=$(readlink -f $(dirname $0))
echo "PWD $PWD"

my_cmd
my_cmd_eval

my_cmd "hahaha"
my_cmd_eval "hahaha"

my_cmd "hahaha" "hee" "hee" "hee"
my_cmd_eval "hahaha" "hee" "hee" "hee"


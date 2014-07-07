#!/bin/bash


function cd_and_cmd()
{
    local my_cmd="pwd"
    cd /tmp || return 1
    eval $my_cmd || return 1
    return 0
}

function my_cd()
{
    local my_cmd="echo 'running pwd:';pwd"
    eval $my_cmd || return 1
    cd /tmp || return 1
    return 0
}

PWD=$(readlink -f $(dirname $0))
echo "PWD $PWD"
pwd
start_dir="$PWD"
echo "start_dir=$start_dir"
echo

(my_cd; echo "in subshell"; echo "PWD $PWD"; pwd; echo) 
echo "back in parent shell"
echo "PWD $PWD"
pwd
echo "start_dir=$start_dir"
echo 

my_cd
echo "PWD $PWD"
pwd
echo "start_dir=$start_dir"
echo


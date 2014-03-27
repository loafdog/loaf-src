#!/bin/bash

function fwk_trap_handler()
{
    fwk_trap_clear_all
    echo "*START TRAP*********************************************************"
    local me="$0"
    local lastline="$1"
    local lasterr="$2"
    local bline="$3"

    local i=${#FUNCNAME[@]}
    local j=${#BASH_LINENO[@]}
    echo "i=$i j=$j"
    echo "funcname ${FUNCNAME[@]}"
    echo "bash_lineno ${BASH_LINENO[@]}"
    for ((k=$i-1; k>0; k--)); do
        echo "${FUNCNAME[$k]} ${BASH_LINENO[$k]}"
    done


    local msg="TRAP src=$me line=$lastline err=$lasterr bline=$bline"
    echo "$msg"
    echo "*END TRAP*********************************************************"
    exit $lasterr
}

function fwk_exit_handler()
{
    fwk_trap_clear_all
    echo "*START EXIT*****************************************"
    local me="$0"
    local lastline="$1"
    local lasterr="$2"
    local bline="$3"

    local i=${#FUNCNAME[@]}
    local j=${#BASH_LINENO[@]}
    echo "i=$i j=$j"
    echo "funcname ${FUNCNAME[@]}"
    echo "bash_lineno ${BASH_LINENO[@]}"
    for ((k=$i-1; k>0; k--)); do
        echo "${FUNCNAME[$k]} ${BASH_LINENO[$k]}"
    done

    local msg="EXIT src=$me line=$lastline err=$lasterr bline=$bline"
    echo "$msg"
    echo "*END EXIT*****************************************"
    exit $lasterr
}

function fwk_trap_set_all()
{
    trap 'fwk_trap_handler ${LINENO} $? ${BASH_LINENO}' ERR
    trap 'fwk_exit_handler ${LINENO} $? ${BASH_LINENO}' INT TERM EXIT

}

function fwk_trap_clear_all()
{
    trap - INT TERM EXIT
    trap - ERR
}


function exit_handler()
{
    local p_lineno="$1"
    local b_lineno="$2"
    echo "--> ERR HANDLER"

    for (( i=${#g_bash_lineno[@]}-1; i>=0; i-- ))
        do
        test ${g_bash_lineno[$i]} -ne 1 && break
    done    

    local g_lineno="${g_bash_lineno[$i]}"

    if test ${p_lineno} -eq 1 && test ${g_lineno} -gt 1
        then
        local lineno="${g_lineno}"
        else
        local lineno="${p_lineno}"
     fi

     local source="${g_bash_source[-1]}"

     echo "LINENO: ${lineno} $b_lineno"
     echo "FILE: ${source}"

     exit
}

function preexec ()
{
    local called=$( caller 0 )
    local lineno=$( echo "$called" | cut -d " " -f1 )
    local source=$( echo "$called" | cut -d " " -f3 )

    if ! eval '[[ ${!g_bash_lineno[@]} ]]' # isset
        then
            g_bash_lineno=( "$lineno" )
        else
            g_bash_lineno=( "${g_bash_lineno[@]}" "$lineno" )
    fi
   
    if ! eval '[[ ${!g_bash_source[@]} ]]' # isset
        then
            g_bash_source=( "$source" )
        else
            g_bash_source=( "${g_bash_source[@]}" "$source" )
    fi
}




function f1_has_error()
{
    echo $foo
    cat hello | grep foo
}

function f2_has_error() {
    f1_has_error
}

function f3_has_error() {
    f2_has_error
}


#############################################################################
# MAIN
#############################################################################

#trap 'exit_handler $LINENO $BASH_LINENO' EXIT 

# doesn't work when accessing unbound var.. oh well.
#trap 'preexec' DEBUG

fwk_trap_set_all

set -eu

f3_has_error
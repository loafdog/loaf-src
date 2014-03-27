#!/bin/bash

# in bash TRUE=0 and FALSE=non-zero
# 
# (( expr )) sets $? to 1 if expr=0, 0 if expr=non-zero
#
# and list executes on true(0): 
#
# rc_zero && cmd # executes cmd
# rc_one && cmd # does not exec cmd
#
# or list executes on false(1 or non-zero): 
#
# rc_zero || cmd # does not exec cmd
# rc_one || cmd # execs cmd




function rc_one()
{
    #echo "${FUNCNAME[0]} called"
    return 1
}

function rc_zero()
{
    #echo "${FUNCNAME[0]} called"
    return 0
}

function test_or_list_one()
{
    echo "${LINENO}:${FUNCNAME[0]}: enter"
    local rc=1
    rc_one || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? $rc || in" # true
    }
    (( rc_one )) || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? (($rc)) || in" # true
    }
    [ rc_one ] || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? [$rc] ||" # false
    }
    echo "${LINENO}:${FUNCNAME[0]}: \$?=$? [$rc] || out" # true
    [[ rc_one ]] || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? [[$rc]] ||" # false
    }
    echo "${LINENO}:${FUNCNAME[0]}: \$?=$? [[$rc]] || out" # true
    echo "${LINENO}:${FUNCNAME[0]}: exit"
}

function test_and_list_one()
{
    echo "${LINENO}:${FUNCNAME[0]}: enter"
    local rc=1
    rc_one && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? $rc && in" # false
    }
    echo "${LINENO}:${FUNCNAME[0]}: \$?=$? $rc && out" # true
    (( rc_one )) && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? (($rc)) && in" # false
    }
    echo "${LINENO}:${FUNCNAME[0]}: \$?=$? (($rc)) && out" # true
    [ rc_one ] && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? [$rc] &&" # true
    }
    [[ rc_one ]] && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? [[$rc]] &&" # true
    }
    echo "${LINENO}:${FUNCNAME[0]}: exit"
}

function test_or_list_zero()
{
    echo "${LINENO}:${FUNCNAME[0]}: enter"
    local rc=0
    rc_zero || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? || $rc" # false
    }
    (( rc_zero )) || { # sets $? to 1 if expr=0, 0 if expr=non-zero
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? || (($rc))" # true
    }
    [ rc_zero ] || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? || [$rc]" # false
    }
    [[ rc_zero ]] || {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? || [[$rc]]" # false
    }
    echo "${LINENO}:${FUNCNAME[0]}: exit"
}

function test_and_list_zero()
{
    echo "${LINENO}:${FUNCNAME[0]}: enter"
    local rc=0
    rc_zero && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? && $rc" # true
    }
    (( rc_zero )) && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? && (($rc))" # false
    }
    [ rc_zero ] && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? && [$rc]" # true
    }
    [[ rc_zero ]] && {
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? && [[$rc]]" # true
    }
    echo "${LINENO}:${FUNCNAME[0]}: exit"
}

function test_one()
{
    echo "${LINENO}:${FUNCNAME[0]}: enter"
    local rc=1

    if rc_one ; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if $rc"
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else $rc" # false
    fi

    if (( rc_one )) ; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if(($rc))"
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else(($rc))" # false
    fi

    if [ rc_one ]; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if[$rc]" # true
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else[$rc]"
    fi

    if [[ rc_one ]]; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if[[$rc]]" # true
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else[[$rc]]"
    fi

    echo "${LINENO}:${FUNCNAME[0]}: exit"
}

function test_zero()
{
    echo "${LINENO}:${FUNCNAME[0]}: enter"
    local rc=0
    if rc_zero ; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if $rc" # true
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else $rc"
    fi

    if (( rc_zero )) ; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if(($rc))"
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else(($rc))" # false
    fi

    if [ rc_zero ]; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if[$rc]" # true
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else[$rc]"
    fi

    if [[ rc_zero ]]; then
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? true/if[[$rc]]" # true
    else
        echo "${LINENO}:${FUNCNAME[0]}: \$?=$? false/else[[$rc]]"
    fi
    echo "${LINENO}:${FUNCNAME[0]}: exit"
}

function test_one2()
{
    rc_one || {
        [[ $? -ne 0 ]] && { echo "${LINENO}:${FUNCNAME[0]}: \$?=$?";}
    }
    rc_one && {
        [[ $? -ne 0 ]] && { echo "${LINENO}:${FUNCNAME[0]}: \$?=$?";}
    }
}

function test_zero2()
{
    rc_zero || {
        [[ $? -ne 0 ]] && { echo "${LINENO}:${FUNCNAME[0]}: \$?=$?";}
    }
    rc_zero && {
        [[ $? -ne 0 ]] && { echo "${LINENO}:${FUNCNAME[0]}: \$?=$?";}
    }
}

# rc_one
# echo $?
# rc_zero
# echo $?

test_or_list_one
test_and_list_one

exit 0

test_and_list_zero
test_or_list_zero

test_one
test_zero

#!/bin/bash


function is_xtrace_on()
{
# $- contains bash options as letters only. Options that don't have
# single letter won't be included in the $- var
    echo "\$-=[$-]"
    case "$-" in
        *x*) echo "xtrace is set"; return 0 ;;
    esac
    return 1
}

set -eu
set -o pipefail
set -o xtrace

# set outputs all env vars. -o flag limits to bash opts only. Good way
# to display opts in user readable form.
set -o

echo "check if xtrace on"
if is_xtrace_on ; then
    echo "xtrace on, turn off"
    set +x
else
    echo "xtrace off"
fi

echo "check if xtrace on"
if is_xtrace_on ; then
    echo "xtrace on, turn off"
    set +x
else
    echo "xtrace off"
fi

echo "check if xtrace off"
if ! is_xtrace_on ; then
    echo "xtrace off, turn on"
    set -x
else
    echo "xtrace on"
fi

is_xtrace_on

#!/bin/bash


function die() 
{
    local frame=0
    local msg=""
    while true; do
        local f
        f=$(caller $frame) || {
            break
        }
        msg+="$f"$'\n'
        ((frame++)) || true;
    done
    echo "$msg $*"

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


function f1() {
    die "*** an error occured ***"
}

function f2() {
    f1
}

function f3() {
    f2
}


function trace()
{
    echo "TRACE" \
         "${BASH_SOURCE[1]}:${BASH_LINENO[0]}:${FUNCNAME[1]}:" \
         "$BASH_COMMAND"
}

set -o functrace
shopt -s extdebug
trap trace DEBUG

#############################################################################
# MAIN
#############################################################################

# If using a trap, without -e/erronexit the caller builtin will not
# print valid stack trace. it only prints the exit trap handler and main.

# The stack trace first entry still shows incorrect line (1), instead
# of the actual line that failed when encountering errors like unbound
# variable (use -u/nounset).

set -eu

f3

echo
echo "now test exitting with error"
echo

f3_has_error
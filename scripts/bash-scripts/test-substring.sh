#!/bin/bash -ex

function do_sub()
{
    local str
    str="$1"
    #echo "str $str"
    # NOTE space after last / is key!!!!
    local parts
    parts=(${str//,/ })
    # echo "num parts ${#parts[@]} : ${parts[@]}"
    if [ ${#parts[@]} -lt 1 ]; then
        return 1
    fi
    local ports
    ports=(${parts[0]//\// })
    #echo "num ports ${#ports[@]} : ${ports[@]}"
    if [ ${#ports[@]} -lt 1 ]; then
        return 1
    fi
    echo "${ports[0]}"
}

teststr="5/0,b/0,c/1"
port=$(do_sub "$teststr")
echo "$? port=$port"

teststr="6/0"
port=$(do_sub "$teststr")
echo "$? port=$port"

teststr="60"
port=$(do_sub "$teststr")
echo "$? port=$port"

teststr=""
port=$(do_sub "$teststr")
echo "$? port=$port"
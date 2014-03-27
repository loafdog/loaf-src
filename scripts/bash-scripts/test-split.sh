#!/bin/bash

function george_get_inter_mac_from_ip()
{
    local ip

    ip="$1"
    echo "ip $ip"
    # NOTE space after last / is key!!!!
    oc=(${ip//./ })

    echo "0 [${oc[0]}]"
    echo "1 ${oc[1]}"
    echo "2 ${oc[2]}"
    echo "3 ${oc[3]}"
}

function split_space()
{
    local str="$1"
    parts=(${str// / })
    echo "num=${#parts[@]} [$str]"
    for part in ${parts[@]}; do
        echo "  $part"
    done 
}

george_get_inter_mac_from_ip "1.2.3.4"

split_space "foo bar"
split_space "foo bar baz"
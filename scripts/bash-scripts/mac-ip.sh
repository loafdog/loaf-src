#!/bin/bash

#############################################################################
function george_get_inter_mac()
{
    if [ "$#" -ne "3" ]; then
        echo "missing arg"
        return 1
    fi
    local dcid="$1"
    local cid="$2"
    local host_addr="$3"
    local mac=$(printf "02:00:%02x:%02x:%02x:%02x" $(($dcid & 63))  $(($cid >> 8)) $(($cid & 255)) $(($host_addr & 255)))
    echo $mac
}

#############################################################################
function george_get_inter_mac_from_ip()
{
    local ip="$1"
    local oc=(${ip//./ })
    local dc=$((${oc[1]} >> 2))
    local ch=$((${oc[1]} & 2 | ${oc[2]}))
    local host=${oc[3]}
    local mac=$(george_get_inter_mac "$dc" "$ch" "$host")
    echo $mac
}

dc=4
ch=1
ccard=192
ip=10.16.1.192

mac1=$(george_get_inter_mac $dc $ch $ccard)
mac2=$(george_get_inter_mac_from_ip $ip)

echo "mac1 $mac1"
echo "mac2 $mac2"
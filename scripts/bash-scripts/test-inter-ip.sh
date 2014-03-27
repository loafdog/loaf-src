#!/bin/bash


function get_inter_ip_mine()
{
    local dc=$1
    local ch=$2

    # INTER_IP format: 10.[DC:6][CH:10].host
    oc21=$((dc << 10)) #2
    oc22=$((ch))
    oc23=$((oc21 | oc22))
    oc2=$((oc23>>8))
    oc3=$((ch & 255))
    echo "10.$oc2.$oc3"
}

function get_inter_ip()
{
    local dc=$1
    local ch=$2

    # INTER_IP format: 10.[DC:6][CH:10].host
    OC21=$((dc << 2)) #2
    OC22=$((ch >> 8))
    OC2=$((OC21 | OC22))
    OC3=$((ch & 255))
    echo "10.$OC2.$OC3"
}

function test_get_inter_ip()
{
    local dc=$1
    local ch=$2
    local host=$3
    local ip=$4
    local prefix=$(get_inter_ip $dc $ch)
    local res="$prefix.$host"
    if [ "$res" != "$ip" ]; then
        printf "FAIL %14s %14s %5s %5s %5s\n" "$res" "$ip" "$dc" "$ch" "$host"
    else
        printf "PASS %14s %14s %5s %5s %5s\n" "$res" "$ip" "$dc" "$ch" "$host"
    fi
}

function ut_get_inter_ip()
{
    printf "     %14s %14s %5s %5s %5s\n" "result" "expected" "dc" "ch" "host"
    # format is: dc ch host expected_ip
    while read -r test; do
        if [ -z "$test" ] || [[ "$test" == \#* ]]; then
            continue
        fi
        test_get_inter_ip $test
    done <<EOF
#
0  0    0   10.0.0.0
0  1    0   10.0.1.0
0  1    1   10.0.1.1
0  1023 2   10.3.255.2
0  2    63  10.0.2.63
0  2    255 10.0.2.255
0  1023 63  10.3.255.63
0  1023 255 10.3.255.255

1  0    0   10.4.0.0
1  1    0   10.4.1.0
1  1    1   10.4.1.1
1  1023 2   10.7.255.2
1  2    63  10.4.2.63
1  2    255 10.4.2.255
1  1023 63  10.7.255.63
1  1023 255 10.7.255.255

62  0    0   10.248.0.0
62  1    0   10.248.1.0
62  1    1   10.248.1.1
62  1023 2   10.251.255.2
62  2    63  10.248.2.63
62  2    255 10.248.2.255
62  1023 63  10.251.255.63
62  1023 255 10.251.255.255

63  0    0   10.252.0.0
63  1    0   10.252.1.0
63  1    1   10.252.1.1
63  1023 2   10.255.255.2
63  2    63  10.252.2.63
63  2    255 10.252.2.255
63  1023 63  10.255.255.63
63  1023 255 10.255.255.255

62  300  128 10.249.44.128

EOF
}

ut_get_inter_ip
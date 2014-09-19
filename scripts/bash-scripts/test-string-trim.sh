#!/bin/bash

function test_trim_both()
{
    # longest substring match from front. Deletes everything up to
    # last / in string
    local s=${1##*/}
    # long substring match from back. Deletes '__done' from end of str
    s=${s%%__done}
    echo "[$1]->[$s]"
}

function test_trim_front_long()
{
    local s=${1##*/}
    echo "front long: [$1]->[$s]"
}

function test_trim_front_short()
{
    local s=${1#*/}
    echo "front short: [$1]->[$s]"
}

function test_trim_back_long()
{
    local s=${1%%/*}
    echo "back long: [$1]->[$s]"
}

function test_trim_back_short()
{
    local s=${1%/*}
    echo "back short:  [$1]->[$s]"
}

str="/genesis/progress/4-2/hyper-4-2-10__done"

test_trim_both $str
echo
test_trim_front_short $str
test_trim_back_short $str
echo
test_trim_front_long $str
test_trim_back_long $str


line="Aug 25 13:16:18 localhost xinetd[35475]: START: tftp pid=37184 from=10.16.2.63"
tftp_pid=${line#*tftp }
tftp_pid=${tftp_pid%*from*}
echo $tftp_pid

line="Aug 25 13:31:19 localhost xinetd[35475]: EXIT: tftp status=0 pid=37184 duration=901(sec)"
tftp_exit=${line#*EXIT:}
echo $tftp_exit
if [[ $tftp_exit == *status=0* ]]; then
    echo "tftp OK"
else
    echo tftp fail
fi

line="Aug 25 13:31:19 localhost xinetd[35475]: EXIT: tftp status=1 pid=37184 duration=901(sec)"
tftp_exit=${line#*EXIT:}
echo $tftp_exit
if [[ $tftp_exit == *status=0* ]]; then
    echo "tftp OK"
else
    echo tftp fail
fi
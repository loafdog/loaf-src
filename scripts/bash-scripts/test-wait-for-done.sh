#!/bin/bash -exu
GENESIS_PROGRESS_DIR=/tmp

function fwk_progress_wait_for_group_done()
{
    local min_wait="$1"
    local max_wait="$2"
    #local id=$(fwk_get_id)
    local id="id"
    echo "args len $# : $@"

    # array of files to wait for
    local wait_files=()
    # array of 0/1 to indicate which done files have appeared
    local done_files=()
    local i=0
    for s in "${@:3}"; do
        echo "saw $s"
        wait_files+=("$GENESIS_PROGRESS_DIR/$id/${s}__done")
        done_files[$i]=0
        ((i++)) || true
    done

    echo "wait files len: ${#wait_files[@]}"
    for s in "${wait_files[@]}"; do
        echo "wait_files: $s"
    done
    num_wait=${#wait_files[@]}

    # DEBUG
    # touch ${wait_files[0]}
    rm -f ${wait_files[0]}


    done_len=${#done_files}
    echo "done len: ${#done_files[@]}"
    local num_done=0
    for s in "${done_files[@]}"; do
        if [ $s == 1 ]; then
            ((num_done++)) || true
        fi
    done
    echo "num_done: $num_done"

    local now=$SECONDS
    local waited=$((SECONDS-now))
    while [ $num_done -lt $num_wait ] && [ "$waited" -lt "$max_wait" ]; do

        sleep 5
        waited=$((SECONDS-now))

        i=0
        for s in "${wait_files[@]}"; do
            echo "check $s"
            if [ -e "$s" ]; then
                done_files[$i]=1
            fi
            ((i++)) || true
        done
        local num_done=0
        for s in "${done_files[@]}"; do
            if [ $s == 1 ]; then
                ((num_done++)) || true
            fi
        done
    done

    echo "found $num_done of $num_wait done files. waited ${waited}s"
    if [ $num_done -lt $num_wait ]; then
        echo "timed out waiting for dones"
        return 
    fi

    return 0
}


function fwk_progress_wait_for_group_done2()
{
    local min_wait="$1"
    local max_wait="$2"
    if [ $max_wait -lt $min_wait ] || [ $max_wait -lt 0 ] || [ $min_wait -lt 0 ]; then
        return 1
    fi
    #local id=$(fwk_get_id)
    local id="id"
    echo "args len $# : $@"

    # array of files to wait for
    local wait_files=()
    for s in "${@:3}"; do
        echo "saw $s"
        wait_files+=("$GENESIS_PROGRESS_DIR/$id/${s}__done")
    done

    num_wait=${#wait_files[@]}
    echo "wait files len: $num_wait"
    for s in "${wait_files[@]}"; do
        echo "wait_files: $s"
        touch $s
    done

    # DEBUG
    #touch ${wait_files[0]}
    #rm -f ${wait_files[0]}

    local now=$SECONDS
    local waited=$((SECONDS-now))
    local num_done=0
    while [ $num_done -lt $num_wait ] && [ $waited -lt $max_wait ]; do
        sleep 5
        waited=$((SECONDS-now))
        num_done=0
        for s in "${wait_files[@]}"; do
            echo "check $s"
            if [ -e "$s" ]; then
                ((num_done++)) || true
            fi
        done
        if [ $num_done -eq $num_wait ]; then
            echo "found all($num_done) done files. waited ${waited}s"
            return 0
        fi
    done

    echo "found $num_done of $num_wait done files. timed out. waited ${waited}s"
    return 1
}


hosts=("foo" "bar")
echo "hosts len: ${#hosts[@]}"
fwk_progress_wait_for_group_done2 5 10 ${hosts[@]}

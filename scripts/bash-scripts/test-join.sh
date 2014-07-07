#!/bin/bash

function join()
{
    local IFS
    IFS="$1"
    shift
    echo "$*"
}

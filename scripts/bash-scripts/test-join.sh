#!/bin/bash

function join()
{
    local IFS
    IFS="$1"
    shift
    # @ doesn't work, use *. If you double quote $*, IFS is used as
    # field delim when printing out.  If
    echo "$*"
}

echo "Create a function to do join, inside it set IFS. IFS only changes in the func"
join "-" a b c
join "-" a b
join "-" a
join "-" 

OLDIFS=$IFS
array=(a b c)

echo  "doesn't work"
IFS='-' echo "first time: ${array[*]}"
echo "next time: ${array[*]}"
IFS=$OLDIFS
echo "test time: ${array[*]}"
echo

echo "works but need to set IFS back"
IFS='-'; echo "first time: ${array[*]}"
echo "next time: ${array[*]}"
IFS=$OLDIFS
echo "test time: ${array[*]}"
echo

echo "works! but creates a subshell"
( IFS='-'; echo "first time: ${array[*]}" )
echo "next time: ${array[*]}"
IFS=$OLDIFS
echo "test time: ${array[*]}"
echo

echo "works but need to set IFS back"
{ IFS='-'; echo "first time: ${array[*]}"; }
echo "next time: ${array[*]}"
IFS=$OLDIFS
echo "test time: ${array[*]}"
echo



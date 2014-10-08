#!/bin/bash

function foo()
{
    echo $
    echo '$'
    echo "$"
}

echo $
echo '$'
echo "$"
foo
echo

function bar()
{
    echo @
    echo '@'
    echo "@"
}

echo @
echo '@'
echo "@"
foo
echo

function echo_special_char()
{
    echo $SPECIAL_CHAR
    echo '$SPECIAL_CHAR'
    echo "$SPECIAL_CHAR"
}

SPECIAL_CHAR='$'
echo_special_char
echo
SPECIAL_CHAR='@'
echo_special_char

#!/bin/bash


set -x

shopt -q extdebug
echo $?

shopt extdebug
echo $?

shopt -q extdebug
echo $?

shopt -s extdebug
echo $?

shopt -q extdebug
echo $?


#shopt -q xtrace
#echo $?

#shopt extglob >/dev/null && extglobWasOff=0
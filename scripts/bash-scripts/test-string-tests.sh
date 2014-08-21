#!/bin/bash

#############################################################################
echo 
echo '$zstr is not declared'
if [[ -z $zstr ]]; then
    echo '[[ -z $zstr ]]  is null'
else
    echo '[[ -z $zstr ]]  is NOT null'
fi

if [[ -z "$zstr" ]]; then
    echo '[[ -z "$zstr" ]] is null'
else
    echo '[[ -z "$zstr" ]] is NOT null'
fi

echo 'declared $zstr= '
zstr=
if [[ -z $zstr ]]; then
    echo '[[ -z $zstr ]]  is null'
else
    echo '[[ -z $zstr ]]  is NOT null'
fi

if [[ -z "$zstr" ]]; then
    echo '[[ -z "$zstr" ]] is null'
else
    echo '[[ -z "$zstr" ]] is NOT null'
fi

zstr=foo
echo "declared \$zstr=$zstr "
if [[ -z $zstr ]]; then
    echo '[[ -z $zstr ]]  is null'
else
    echo '[[ -z $zstr ]]  is NOT null'
fi

if [[ -z "$zstr" ]]; then
    echo '[[ -z "$zstr" ]] is null'
else
    echo '[[ -z "$zstr" ]] is NOT null'
fi

#############################################################################
echo 
echo '$zsstr is not declared'
if [ -z $zsstr ]; then
    echo '[ -z $zsstr ]  is null'
else
    echo '[ -z $zsstr ]  is NOT null'
fi

if [ -z "$zsstr" ]; then
    echo '[ -z "$zsstr" ] is null'
else
    echo '[ -z "$zsstr" ] is NOT null'
fi

echo 'declared $zsstr= '
zsstr=
if [ -z $zsstr ]; then
    echo '[ -z $zsstr ]  is null'
else
    echo '[ -z $zsstr ]  is NOT null'
fi

if [ -z "$zsstr" ]; then
    echo '[ -z "$zsstr" ] is null'
else
    echo '[ -z "$zsstr" ] is NOT null'
fi

zsstr=foo
echo "declared \$zsstr=$zsstr "
if [ -z $zsstr ]; then
    echo '[ -z $zsstr ]  is null'
else
    echo '[ -z $zsstr ]  is NOT null'
fi

if [ -z "$zsstr" ]; then
    echo '[ -z "$zsstr" ] is null'
else
    echo '[ -z "$zsstr" ] is NOT null'
fi


#############################################################################
echo 
echo '$nstr is not declared'
if [[ -n $nstr ]]; then
    echo '[[ -n $nstr ]] is NOT null'
else
    echo '[[ -n $nstr ]] is null'
fi

if [[ -n "$nstr" ]]; then
    echo '[[ -n "$nstr" ]] is NOT null'
else
    echo '[[ -n "$nstr" ]] is null'
fi

echo 'declared $nstr= '
nstr=
if [[ -n $nstr ]]; then
    echo '[[ -n $nstr ]] is NOT null'
else
    echo '[[ -n $nstr ]] is null'
fi

if [[ -n "$nstr" ]]; then
    echo '[[ -n "$nstr" ]] is NOT null'
else
    echo '[[ -n "$nstr" ]] is null'
fi

nstr=foo
echo "declared \$nstr=$nstr "
if [[ -n $nstr ]]; then
    echo '[[ -n $nstr ]] is NOT null'
else
    echo '[[ -n $nstr ]] is null'
fi

if [[ -n "$nstr" ]]; then
    echo '[[ -n "$nstr" ]] is NOT null'
else
    echo '[[ -n "$nstr" ]] is null'
fi


#############################################################################
echo 
echo '$nsstr is not declared'
if [ -n $nsstr ]; then
    echo '[ -n $nsstr ] is NOT null : unquoted test with [ and -n doesnt work right'
else
    echo '[ -n $nsstr ] is null'
fi

if [ -n "$nsstr" ]; then
    echo '[ -n "$nsstr" ] is NOT null'
else
    echo '[ -n "$nsstr" ] is null'
fi

echo 'declared $nsstr= '
nsstr=
if [ -n $nsstr ]; then
    echo '[ -n $nsstr ] is NOT null : unquoted test with [ and -n doesnt work right'
else
    echo '[ -n $nsstr ] is null'
fi

if [ -n "$nsstr" ]; then
    echo '[ -n "$nsstr" ] is NOT null'
else
    echo '[ -n "$nsstr" ] is null'
fi

nsstr=foo
echo "declared \$nsstr=$nsstr "
if [ -n $nsstr ]; then
    echo '[ -n $nsstr ] is NOT null'
else
    echo '[ -n $nsstr ] is null'
fi

if [ -n "$nsstr" ]; then
    echo '[ -n "$nsstr" ] is NOT null'
else
    echo '[ -n "$nsstr" ] is null'
fi

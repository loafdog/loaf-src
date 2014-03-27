#!/bin/bash

function generate_password()
{
    local password="$1"
    # RANDOM is internal bash variable
    local rand_file=/tmp/$RANDOM.rand
    dd if=/dev/urandom of=$rand_file bs=12 count=1 >/dev/null 2>&1 || return 2
    local salt=$(base64 < $rand_file)
    rm $rand_file
    # The crypt func 2nd arg, salt, is of the form $digest$salt$.  The
    # result is of the form $digest$salt$hash where has is the hashed
    # password. The salt arg must include the 3 '$' in it to generate
    # a sha512
    local sha=$(perl -e "print crypt(\"$password\", '\$6\$"$salt"\$')")
    if [ -z "$sha" ]; then
        exit 1
    fi
    echo "$sha"
}

function generate_cobbler_password()
{
    local password=$1
    local cobdig=$(perl -e "use Digest::MD5; print Digest::MD5::md5_he('cobbler:Cobbler:"$password"')")
}

function generate_cobbler_password2()
{
    local password=$1
    perl -e "use Digest::MD5; print Digest::MD5::md5_he('cobbler:Cobbler:"$password"')"
}

function generate_cobbler_password3()
{
    local password=$1
    local cobdig=$(perl -e "use Digest::MD5; print Digest::MD5::md5_hex('cobbler:Cobbler:"$password"')"; return $?)
    rc=$?
    echo $cobdig
}

function generate_cobbler_password4()
{

    local password=$1
    local cobdig
    cobdig=$(perl -e "use Digest::MD5; print Digest::MD5::md5_he('cobbler:Cobbler:"$password"')")
    perlrc=$?
    echo $cobdig
    return $perlrc
}



PASSWORD="ge.orge"
#COBBLER_DIGEST=$(generate_cobbler_password2 $PASSWORD)
echo "dig2 rc=$?"

COBBLER_DIGEST=$(generate_cobbler_password3 $PASSWORD)
echo "dig3 rc=$?"

COBBLER_DIGEST=$(generate_cobbler_password4 $PASSWORD)
echo "dig4 rc=$?"

#SHA512_PASSWORD=$(generate_password $PASSWORD)
#echo "sha rc=$?"
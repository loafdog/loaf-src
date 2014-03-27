#!/bin/bash


function do_sed()
{
    local p="$1"
    echo "setting password 1=[$1] p=[$p]"
    sed -e "s/^PASSWORD=.*/PASSWORD=$1/g" /tmp/password.template > /tmp/password
    cat /tmp/password
}

function setup_password_file()
{
    cat <<EOF > "/tmp/password.template"
PASSWORD=
EOF
}

setup_password_file

do_sed "Arr.Ikb7"

do_sed "Arr$Ikb7"
do_sed 'Arr$Ikb7'
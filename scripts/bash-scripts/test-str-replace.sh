#!/bin/bash

# use bash to replace string
str="primary_conninfo = 'host=10.10.1.128 port=5432 user=replicator password=xxxxxxx'"

echo "str=[$str]"

new_str=${str/host=* port/host=1.2.3.4 port}

echo "new_str=[$new_str]"

# use sed to replace string

sed_str=$(echo "$str" | sed -e 's/host=.* port/host=1.2.3.4 port/')

echo "sed_str=[$sed_str]"
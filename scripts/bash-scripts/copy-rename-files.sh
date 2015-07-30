#!/bin/bash
echo "$1"
shopt -s globstar
for file in $1; do 
    if [[ -f "$file" ]]; then
        dirname="${file%/*}/"
        #echo "dirname=$dirname"
        basename="${file:${#dirname}}"
        dest=${basename%.*}.j2
        echo "basename=$basename dest=$dest"
        cp "$file" "$dest"
    fi
done

#!/bin/bash

# $1 is name of file to get history of.
# rest of args are supplied to git blame
# 

f=$1
shift

# git log prints out hash and then the file
#{ git log --pretty=format:%H -- "$f"; echo; } | {
{ git log --pretty=format:"%H | %ad | %an"  -- "$f"; echo; } | {
  while read logline; do
    echo "--- $logline"
    # split line by spaces, note space after last / is needed
    parts=(${logline// / })
    hash=${parts[0]}
    git blame $@ $hash -- "$f" | sed 's/^/  /'
  done
}
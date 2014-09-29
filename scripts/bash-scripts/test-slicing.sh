#!/bin/bash


array=(
    "zero"
    "one"
    "two"
    "three"
)

len=${#array[@]}
last=$(($len - 1))

PWD=$(readlink -f $(dirname $0))
echo "PWD $PWD"

echo "  whole array=[${array[@]}]"
echo "array[0]=[${array[0]}]"
echo "array[1]=[${array[1]}]"
echo "..."
echo "array[$last]=[${array[$last]}]"
echo "array[$len]=[${array[$len]}]"
echo
echo "test array slicing \$\{array[@]:N:M}"
echo "  where N is first elem"
echo "  where M is length of slice"
echo
echo "drop first elem"
echo "array[1:rest]=[${array[@]:1}]"
echo
echo "drop last elem"
echo "  whole array=[${array[@]}]"
echo "array[0:last-1]=[${array[@]::$last}]"
echo "array[0:last-1]=[${array[@]:0:$last}]"
echo
echo "drop last 2 elem"
echo "  whole array=[${array[@]}]"
echo
echo "array[:-2]=[${array[@]:-2}]"
echo "array[:(-2)]=[${array[@]:(-2)}]"

# This doesn't work.. can't have M < 0
#echo "array[:0:-2]=[${array[@]:0:-2}]"
#echo "array[:0:(-2)]=[${array[@]:0:(-2)}]"

echo "array[:len-2]=[${array[@]:(($len-2))}]"
echo "This works!"
echo "array[:0:len-2]=[${array[@]:0:(($len-2))}]"
echo

echo "drop all but first"
echo "  whole array=[${array[@]}]"
echo "array[0]=[${array[@]::1}]"
echo "array[0]=[${array[@]:0:1}]"
echo
echo "drop all but first two elems"
echo "  whole array=[${array[@]}]"
echo "array[0]=[${array[@]::2}]"
echo "array[0]=[${array[@]:0:2}]"
echo
echo "drop last elem doesn't work if u specify array len"
echo "  whole array=[${array[@]}]"
echo "array[0:last-1]=[${array[@]:0:$len}]"
echo
echo "skip first two elems and print rest"
echo "  whole array=[${array[@]}]"
echo "  use no M seems best"
echo "array[2:last]=[${array[@]:2}]"
echo "  use len"
echo "len=$len array[2:len]=[${array[@]:2:$len}]"
echo "  use last"
echo "last=$last array[2:last]=[${array[@]:2:$last}]"
echo "  use empty M"
echo "array[2:]=[${array[@]:2:}]"

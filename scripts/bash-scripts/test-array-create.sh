#/bin/bash

make_str()
{
    echo "str_$1"
}
#echo make_str("a")
#echo $(make_str("a"))

test1()
{
    arr=($(make_str("a"))
        $(make_str("b"))
    )
    echo "${arr[@]}"
}
test1


test_assign()
{
    local yings=(0 1 2)
    local yangs=()

    local i=0
    for yin in ${yings[@]}; do
        yangs[$i]="$yin"
        ((i++)) || true
    done
    echo "yings ${yings[@]}"
    echo "yangs ${yangs[@]}"
}
test_assign
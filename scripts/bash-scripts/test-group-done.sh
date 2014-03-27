#!/bin/bash

. /genesis/fwk-parse-args.sh
fwk_parse_args $*
. /genesis/genesis-framework.sh
export ID=$(fwk_make_id "$dcid" "$chid" )
CONFIG_SET=config-set-hypervisor
fwk_init_log "$BASH_SOURCE" "$ID" "$CONFIG_SET"
PWD=$(readlink -f $(dirname $0))
echo "running $BASH_SOURCE in $PWD"

# #################################################################

. $GENESIS_CONFIG_DIR/config
. $GENESIS_CONFIG_DIR/config-internal
. $GENESIS_DIR/george-common.sh

names=()
for i in "${BOOTSTRAP[@]}"; do
    name=$(fwk_get_hyper_hostname "$DATA_CENTER_ID" "$CHASSIS_ID" "$i")
    names+=($name)
done

wait_status=0
not_found=($(fwk_progress_is_group_done 1 2 ${names[@]})) || {
    wait_status=$?
}
echo "wait_status=$wait_status"
echo "num not found=${#not_found[@]} of ${#names[@]}"
if [ $wait_status -eq 2 ]; then
    echo "${not_found[@]}"
fi

echo "=========================================="

not_found=($(fwk_progress_wait_for_group_done 0 10 1 2 ${names[@]})) || {
    wait_status=$?
}
echo "wait_status=$wait_status"
if [ $wait_status -eq 2 ]; then
    echo "${not_found[@]}"
fi

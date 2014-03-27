GENESIS_LOG_DIR=/tmp
GENESIS_LOG_FILE=genesis.log

#############################################################################
function fwk_init_log()
{
    local log_file="run.log"
    local log_dir=$GENESIS_LOG_DIR

    if [ "$#" -gt "0" ]; then
        log_file=${1##*/}
        log_file=${log_file%%.*}
        log_file="$log_file.log"

        if [ "$#" -gt "1" ]; then
            if [ "$2" != "" ]; then
                log_dir="$log_dir/$2"
            fi

            if [ "$#" -gt "2" ]; then
                if [ "$3" != "" ]; then
                    log_dir="$log_dir/$3"
                fi
            fi
        fi
    fi
    # set up logging for config set. The output goes to a master file
    # and to a per config-set file
    mkdir -p $log_dir &> /dev/null
    mv "$log_dir/$log_file" "$log_dir/$log_file.1" &> /dev/null || echo
    exec > >(tee "$log_dir/$log_file" >> $GENESIS_LOG_FILE) 2>&1
    date
}



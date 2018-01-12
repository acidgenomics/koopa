# Profile settings
. "$SEQCLOUD_DIR"/profile/general.sh
if [[ "$SEQCLOUD_CONSOLE" != false ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/console \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi
if [[ "$SEQCLOUD_PATH" != false ]]; then
    for file in $(find "$SEQCLOUD_DIR"/profile/path \
        -type f -name "*.sh" ! -name ".*" | sort); do
        . "$file"
    done
    unset -v file
fi

# Pass positional parameters to scripts in the `bash` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "$SEQCLOUD_DIR"/scripts/"$script".sh $*
}

# Login message for interactive session
. "$SEQCLOUD_DIR"/load/hpc_login_message.sh

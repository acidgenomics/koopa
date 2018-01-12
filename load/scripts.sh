# Pass positional parameters to scripts in the `bash` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "$SEQCLOUD_DIR"/scripts/"$script".sh $*
}

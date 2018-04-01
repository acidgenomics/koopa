# Pass positional parameters to scripts in the `functions` subdirectory
function seqcloud {
    local script="$1"
    shift 1
    . "${SEQCLOUD_DIR}/functions/${script}.sh" $*
}

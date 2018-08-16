# Pass positional parameters to scripts in the `functions` subdirectory
function koopa {
    local script="$1"
    shift 1
    . "${SEQCLOUD_DIR}/functions/${script}.sh" $*
}

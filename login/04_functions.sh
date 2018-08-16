# Pass positional parameters to scripts in the `functions` subdirectory
function koopa {
    local script="$1"
    shift 1
    . "${KOOPA_DIR}/functions/${script}.sh" $*
}

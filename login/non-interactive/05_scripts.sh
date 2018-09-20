# Pass positional parameters to scripts.
function koopa {
    local script="$1"
    shift 1
    source "${KOOPA_BASEDIR}/scripts/${script}.sh" $*
}

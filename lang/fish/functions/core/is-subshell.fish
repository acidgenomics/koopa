function _koopa_is_subshell
    # Is the current shell a koopa subshell?
    # @note Updated 2026-05-01.
    set -q KOOPA_SUBSHELL; and test "$KOOPA_SUBSHELL" -eq 1
end

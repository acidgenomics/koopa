function _koopa_activate_zoxide
    # Activate zoxide.
    # @note Updated 2026-05-01.
    set -l zoxide (_koopa_bin_prefix)/zoxide
    if not test -x "$zoxide"
        return 0
    end
    functions -q z; and functions -e z
    $zoxide init fish | source
end

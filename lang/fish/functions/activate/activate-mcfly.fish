function _koopa_activate_mcfly
    # Activate mcfly shell history search.
    # @note Updated 2026-05-01.
    set -l mcfly (_koopa_bin_prefix)/mcfly
    if not test -x "$mcfly"
        return 0
    end
    $mcfly init fish | source
end

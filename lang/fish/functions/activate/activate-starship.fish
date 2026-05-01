function _koopa_activate_starship
    # Activate starship cross-shell prompt.
    # @note Updated 2026-05-01.
    set -l starship (_koopa_bin_prefix)/starship
    if not test -x "$starship"
        return 0
    end
    $starship init fish | source
end

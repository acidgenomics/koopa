function _koopa_activate_mcfly
    # Activate mcfly shell history search.
    # @note Updated 2026-05-31.
    set -l mcfly "$KOOPA_PREFIX/bin/mcfly"
    if not test -x "$mcfly"
        return 0
    end
    _koopa_activate_mcfly_colors
    set -gx MCFLY_DISABLE_MENU true
    set -gx MCFLY_FUZZY 2
    set -gx MCFLY_HISTORY_LIMIT 10000
    set -gx MCFLY_INTERFACE_VIEW TOP
    set -gx MCFLY_RESULTS 50
    set -gx MCFLY_RESULTS_SORT RANK
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/mcfly-fish.fish"
    if not test -f "$cache_file"; or test "$mcfly" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        $mcfly init fish > "$cache_file"
    end
    source "$cache_file"
end

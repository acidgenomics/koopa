function _koopa_activate_starship
    # Activate starship cross-shell prompt.
    # @note Updated 2026-05-31.
    set -l starship "$KOOPA_PREFIX/bin/starship"
    if not test -x "$starship"
        return 0
    end
    set -gx STARSHIP_LOG error
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/starship-fish.fish"
    if not test -f "$cache_file"; or test "$starship" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        $starship init fish > "$cache_file"
    end
    source "$cache_file"
end

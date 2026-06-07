function _koopa_activate_zoxide
    # Activate zoxide.
    # @note Updated 2026-05-31.
    set -l zoxide "$KOOPA_PREFIX/bin/zoxide"
    if not test -x "$zoxide"
        return 0
    end
    functions -q z; and functions -e z
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/zoxide-fish.fish"
    if not test -f "$cache_file"; or test "$zoxide" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        $zoxide init fish > "$cache_file"
    end
    source "$cache_file"
end

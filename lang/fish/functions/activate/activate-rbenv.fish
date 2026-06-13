function _koopa_activate_rbenv
    # Activate rbenv for fish shell.
    # @note Updated 2026-06-13.
    set -q RBENV_ROOT; and return 0
    set -l prefix "$KOOPA_PREFIX/opt/rbenv"
    if not test -d "$prefix"
        return 0
    end
    set -l rbenv "$prefix/bin/rbenv"
    if not test -r "$rbenv"
        return 0
    end
    set -gx RBENV_ROOT "$prefix"
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/rbenv-fish.fish"
    if not test -f "$cache_file"; or test "$rbenv" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        "$rbenv" init - fish > "$cache_file"
    end
    source "$cache_file"
    functions -q rbenv; and functions -e rbenv
end

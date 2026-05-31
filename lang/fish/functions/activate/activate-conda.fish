function _koopa_activate_conda
    # Activate conda.
    # @note Updated 2026-05-31.
    set -l prefix "$KOOPA_PREFIX/opt/conda"
    if not test -d "$prefix"
        return 0
    end
    set -l conda "$prefix/bin/conda"
    if not test -x "$conda"
        return 0
    end
    functions -q conda; and functions -e conda
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/conda-fish.fish"
    if not test -f "$cache_file"; or test "$conda" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        $conda shell.fish hook > "$cache_file"
    end
    source "$cache_file"
end

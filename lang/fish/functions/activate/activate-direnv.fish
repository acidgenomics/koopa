function _koopa_activate_direnv
    # Activate direnv.
    # @note Updated 2026-05-31.
    set -l direnv "$KOOPA_PREFIX/bin/direnv"
    if not test -x "$direnv"
        return 0
    end
    set -e DIRENV_DIFF
    set -e DIRENV_DIR
    set -e DIRENV_FILE
    set -e DIRENV_WATCHES
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/direnv-hook-fish.fish"
    if not test -f "$cache_file"; or test "$direnv" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        $direnv hook fish > "$cache_file"
    end
    source "$cache_file"
    eval ($direnv export fish)
end

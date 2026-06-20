function _koopa_activate_pyenv
    # Activate pyenv with virtualenv-init for fish shell.
    # @note Updated 2026-06-13.
    set -q PYENV_ROOT; and return 0
    set -l prefix "$KOOPA_PREFIX/opt/pyenv"
    if not test -d "$prefix"
        return 0
    end
    set -l pyenv "$prefix/bin/pyenv"
    if not test -r "$pyenv"
        return 0
    end
    set -gx PYENV_ROOT "$prefix"
    set -gx PYENV_LOCAL_SHIM "$HOME/.pyenv_local_shim"
    if not test -d "$PYENV_LOCAL_SHIM"
        mkdir -p "$PYENV_LOCAL_SHIM"
    end
    _koopa_add_to_path_start "$PYENV_LOCAL_SHIM"
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/pyenv-fish.fish"
    if not test -f "$cache_file"; or test "$pyenv" -nt "$cache_file"
        mkdir -p (path dirname "$cache_file")
        "$pyenv" virtualenv-init - fish > "$cache_file"
    end
    source "$cache_file"
    functions -q pyenv; and functions -e pyenv
end

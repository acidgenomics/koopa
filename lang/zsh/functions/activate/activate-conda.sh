#!/usr/bin/env zsh

_koopa_activate_conda() {
    local prefix
    prefix="${KOOPA_PREFIX:?}/opt/conda"
    if [[ ! -d "$prefix" ]]
    then
        return 0
    fi
    local conda
    conda="${prefix}/bin/conda"
    if [[ ! -x "$conda" ]]
    then
        return 0
    fi
    local shell
    shell="${KOOPA_SHELL##*/}"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            shell='posix'
            ;;
    esac
    (( ${+aliases[conda]} )) && unalias conda
    local cache_file="${XDG_CACHE_HOME:?}/koopa/shell-init/conda-${shell}.sh"
    if [[ ! -f "$cache_file" ]] || [[ "$conda" -nt "$cache_file" ]]; then
        mkdir -p "${cache_file%/*}"
        "$conda" "shell.${shell}" 'hook' > "$cache_file"
    fi
    source "$cache_file"
    return 0
}

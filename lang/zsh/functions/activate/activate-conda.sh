#!/usr/bin/env zsh

_koopa_activate_conda() {
    local prefix
    prefix="$(_koopa_conda_prefix)"
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
    shell="$(_koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            shell='posix'
            ;;
    esac
    local conda_setup
    conda_setup="$("$conda" "shell.${shell}" 'hook')"
    eval "$conda_setup"
    _koopa_is_function 'conda' || return 1
    return 0
}

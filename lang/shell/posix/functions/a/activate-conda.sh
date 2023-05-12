#!/bin/sh

_koopa_activate_conda() {
    # """
    # Activate conda.
    # @note Updated 2023-05-12.
    #
    # @seealso
    # - https://conda.io/projects/conda/en/latest/user-guide/
    #     getting-started.html
    # - conda shell.bash hook
    # - conda shell.posix hook
    # - conda shell.zsh hook
    # - conda init <shell>
    # """
    __kvar_prefix="$(_koopa_conda_prefix)"
    if [ ! -d "$__kvar_prefix" ]
    then
        unset -v __kvar_prefix
        return 0
    fi
    __kvar_conda="${__kvar_prefix}/bin/conda"
    if [ ! -x "$__kvar_conda" ]
    then
        unset -v __kvar_conda __kvar_prefix
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            __kvar_shell='posix'
            ;;
    esac
    __kvar_conda_setup="$("$__kvar_conda" "shell.${__kvar_shell}" 'hook')"
    eval "$__kvar_conda_setup"
    _koopa_is_function 'conda' || return 1
    unset -v \
        __kvar_conda \
        __kvar_conda_setup \
        __kvar_prefix
    return 0
}

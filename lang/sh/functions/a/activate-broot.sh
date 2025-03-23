#!/bin/sh

_koopa_activate_broot() {
    # """
    # Activate broot directory tree utility.
    # @note Updated 2023-06-29.
    #
    # The br function script must be sourced for activation.
    # See 'broot --install' for details.
    #
    # Configuration file gets saved at '${prefs_dir}/conf.toml'.
    # Fish: launcher/fish/br.sh (also saved in Fish functions)
    #
    # Note that for macOS, we're assuming installation via Homebrew.
    # If installed as crate, it will use the same path as for Linux.
    #
    # @seealso
    # https://github.com/Canop/broot
    # """
    [ -x "$(_koopa_bin_prefix)/broot" ] || return 0
    __kvar_config_dir="$(_koopa_xdg_config_home)/broot"
    if [ ! -d "$__kvar_config_dir" ]
    then
        unset -v __kvar_config_dir
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v \
                __kvar_config_dir \
                __kvar_shell
            return 0
            ;;
    esac
    # This is supported for Bash and Zsh.
    __kvar_script="${__kvar_config_dir}/launcher/bash/br"
    if [ ! -f "$__kvar_script" ]
    then
        unset -v \
            __kvar_config_dir \
            __kvar_script \
            __kvar_shell \
        return 0
    fi
    _koopa_is_alias 'br' && unalias 'br'
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    # shellcheck source=/dev/null
    . "$__kvar_script"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_config_dir \
        __kvar_nounset \
        __kvar_script \
        __kvar_shell
    return 0
}

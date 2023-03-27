#!/bin/sh

_koopa_activate_zoxide() {
    # """
    # Activate zoxide.
    # @note Updated 2023-03-27.
    #
    # Highly recommended to use along with fzf.
    #
    # @seealso
    # - https://github.com/ajeetdsouza/zoxide
    # """
    __kvar_zoxide="$(_koopa_bin_prefix)/zoxide"
    if [ ! -x "$__kvar_zoxide" ]
    then
        unset -v __kvar_zoxide
        return 0
    fi
    _koopa_is_alias 'zoxide' && unalias 'zoxide'
    __kvar_shell="$(_koopa_shell_name)"
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            eval "$("$__kvar_zoxide" init "$__kvar_shell")"
            ;;
        *)
            eval "$("$__kvar_zoxide" init 'posix' --hook 'prompt')"
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_nounset \
        __kvar_shell \
        __kvar_zoxide
    return 0
}

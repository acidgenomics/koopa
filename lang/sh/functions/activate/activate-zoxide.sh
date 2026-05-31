#!/bin/sh

_koopa_activate_zoxide() {
    # """
    # Activate zoxide.
    # @note Updated 2023-05-11.
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
    __kvar_shell="${KOOPA_SHELL##*/}"
    __kvar_nounset=0
    case "$-" in *u*) __kvar_nounset=1 ;; esac
    [ "$__kvar_nounset" -eq 1 ] && set +u
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            eval "$("$__kvar_zoxide" init "$__kvar_shell")"
            ;;
        *)
            eval "$("$__kvar_zoxide" init 'posix' --hook 'prompt')"
            ;;
    esac
    [ "$__kvar_nounset" -eq 1 ] && set -u
    unset -v \
        __kvar_nounset \
        __kvar_shell \
        __kvar_zoxide
    return 0
}

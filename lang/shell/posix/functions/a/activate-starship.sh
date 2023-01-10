#!/bin/sh

koopa_activate_starship() {
    # """
    # Activate starship prompt.
    # @note Updated 2022-05-12.
    #
    # Note that 'starship.bash' script has unbound PREEXEC_READY.
    # https://github.com/starship/starship/blob/master/src/init/starship.bash
    #
    # See also:
    # https://starship.rs/
    # """
    local nounset shell
    [ -x "$(koopa_bin_prefix)/starship" ] || return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    unset -v STARSHIP_SESSION_KEY STARSHIP_SHELL
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && return 0
    eval "$(starship init "$shell")"
    return 0
}

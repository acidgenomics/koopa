#!/bin/sh

# FIXME This is failing to load for zsh loaded inside bash shell.

_koopa_activate_starship() {
    # """
    # Activate starship prompt.
    # @note Updated 2025-01-03.
    #
    # Note that 'starship.bash' script has unbound PREEXEC_READY.
    # https://github.com/starship/starship/blob/master/src/init/starship.bash
    #
    # See also:
    # https://starship.rs/
    # """
    [ -n "${STARSHIP_SHELL:-}" ] && return 0
    __kvar_starship="$(_koopa_bin_prefix)/starship"
    if [ ! -x "$__kvar_starship" ]
    then
        unset -v __kvar_starship
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v __kvar_shell
            return 0
            ;;
    esac
    __kvar_nounset="$(_koopa_boolean_nounset)"
    if [ "$__kvar_nounset" -eq 1 ]
    then
        unset -v \
            __kvar_nounset \
            __kvar_shell \
            __kvar_starship
        return 0
    fi
    eval "$("$__kvar_starship" init "$__kvar_shell")"
    unset -v \
            __kvar_nounset \
            __kvar_shell \
            __kvar_starship
    return 0
}

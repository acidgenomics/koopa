#!/usr/bin/env bash

_koopa_activate_starship() {
    local starship
    starship="$(_koopa_bin_prefix)/starship"
    if [[ ! -x "$starship" ]]
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
            return 0
            ;;
    esac
    if [[ -n "${STARSHIP_SHELL:-}" ]] && [[ "$STARSHIP_SHELL" != "$shell" ]]
    then
        unset -v STARSHIP_SHELL
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    if [[ "$nounset" -eq 1 ]]
    then
        return 0
    fi
    eval "$("$starship" init "$shell")"
    return 0
}

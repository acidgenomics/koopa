#!/usr/bin/env zsh

_koopa_activate_zoxide() {
    local zoxide
    zoxide="$(_koopa_bin_prefix)/zoxide"
    if [[ ! -x "$zoxide" ]]
    then
        return 0
    fi
    _koopa_is_alias 'z' && unalias 'z'
    local shell
    shell="$(_koopa_shell_name)"
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    case "$shell" in
        'bash' | \
        'zsh')
            eval "$("$zoxide" init "$shell")"
            ;;
        *)
            eval "$("$zoxide" init 'posix' --hook 'prompt')"
            ;;
    esac
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

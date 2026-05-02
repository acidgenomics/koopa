#!/usr/bin/env zsh

_koopa_activate_broot() {
    [[ -x "$(_koopa_bin_prefix)/broot" ]] || return 0
    local config_dir
    config_dir="$(_koopa_xdg_config_home)/broot"
    if [[ ! -d "$config_dir" ]]
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
    local script
    script="${config_dir}/launcher/bash/br"
    if [[ ! -f "$script" ]]
    then
        return 0
    fi
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$script"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

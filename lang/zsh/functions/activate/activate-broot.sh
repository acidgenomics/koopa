#!/usr/bin/env zsh

_koopa_activate_broot() {
    [[ -x "${KOOPA_PREFIX:?}/bin/broot" ]] || return 0
    local config_dir
    config_dir="${XDG_CONFIG_HOME:?}/broot"
    if [[ ! -d "$config_dir" ]]
    then
        return 0
    fi
    local shell
    shell="${KOOPA_SHELL##*/}"
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
    local nounset=0
    [[ -o nounset ]] && nounset=1
    [[ "$nounset" -eq 1 ]] && set +o nounset
    source "$script"
    unalias br 2>/dev/null || true
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

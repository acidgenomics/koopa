#!/usr/bin/env zsh

_koopa_activate_mcfly() {
    [[ "${__MCFLY_LOADED:-}" = 'loaded' ]] && return 0
    _koopa_is_root && return 0
    local mcfly
    mcfly="$(_koopa_bin_prefix)/mcfly"
    if [[ ! -x "$mcfly" ]]
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
    local color_mode
    color_mode="$(_koopa_color_mode)"
    [[ "$color_mode" = 'light' ]] && export MCFLY_LIGHT=true
    case "${EDITOR:-}" in
        'nvim' | *'/nvim' | \
        'vim' | *'/vim')
            export MCFLY_KEY_SCHEME='vim'
            ;;
        'emacs' | *'/emacs')
            export MCFLY_KEY_SCHEME='emacs'
            ;;
    esac
    export MCFLY_DISABLE_MENU=true
    export MCFLY_FUZZY=2
    export MCFLY_HISTORY_LIMIT=10000
    export MCFLY_INTERFACE_VIEW='TOP'
    export MCFLY_RESULTS=50
    export MCFLY_RESULTS_SORT='RANK'
    local nounset
    nounset="$(_koopa_boolean_nounset)"
    [[ "$nounset" -eq 1 ]] && set +o nounset
    eval "$("$mcfly" init "$shell")"
    [[ "$nounset" -eq 1 ]] && set -o nounset
    return 0
}

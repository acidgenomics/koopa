#!/bin/sh

_koopa_activate_mcfly() {
    # """
    # Activate mcfly.
    # @note Updated 2023-02-01.
    #
    # Use "mcfly search 'query'" to query directly.
    # """
    local color_mode nounset shell
    [ "${__MCFLY_LOADED:-}" = 'loaded' ] && return 0
    [ -x "$(koopa_bin_prefix)/mcfly" ] || return 0
    _koopa_is_root && return 0
    shell="$(koopa_shell_name)"
    case "$shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            return 0
            ;;
    esac
    color_mode="$(koopa_color_mode)"
    [ "$color_mode" = 'light' ] && export MCFLY_LIGHT=true
    case "${EDITOR:-}" in
        'emacs' | \
        'vim')
            export MCFLY_KEY_SCHEME="${EDITOR:?}"
        ;;
    esac
    export MCFLY_FUZZY=2
    export MCFLY_HISTORY_LIMIT=10000
    export MCFLY_INTERFACE_VIEW='TOP' # or 'BOTTOM'
    export MCFLY_KEY_SCHEME='vim'
    export MCFLY_RESULTS=50
    export MCFLY_RESULTS_SORT='RANK' # or 'LAST_RUN'
    nounset="$(koopa_boolean_nounset)"
    [ "$nounset" -eq 1 ] && set +o nounset
    eval "$(mcfly init "$shell")"
    [ "$nounset" -eq 1 ] && set -o nounset
    return 0
}

#!/bin/sh

_koopa_activate_mcfly() {
    # """
    # Activate mcfly.
    # @note Updated 2023-03-10.
    #
    # Use "mcfly search 'query'" to query directly.
    #
    # Light mode is still buggy:
    # - https://github.com/cantino/mcfly/issues/150
    # - https://github.com/cantino/mcfly/issues/386
    # """
    [ "${__MCFLY_LOADED:-}" = 'loaded' ] && return 0
    _koopa_is_root && return 0
    __kvar_mcfly="$(_koopa_bin_prefix)/mcfly"
    if [ ! -x "$__kvar_mcfly" ]
    then
        unset -v __kvar_mcfly
        return 0
    fi
    __kvar_shell="$(_koopa_shell_name)"
    case "$__kvar_shell" in
        'bash' | \
        'zsh')
            ;;
        *)
            unset -v \
                __kvar_mcfly \
                __kvar_shell
            return 0
            ;;
    esac
    __kvar_color_mode="$(_koopa_color_mode)"
    [ "$__kvar_color_mode" = 'light' ] && export MCFLY_LIGHT=true
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
    __kvar_nounset="$(_koopa_boolean_nounset)"
    [ "$__kvar_nounset" -eq 1 ] && set +o nounset
    eval "$("$__kvar_mcfly" init "$__kvar_shell")"
    [ "$__kvar_nounset" -eq 1 ] && set -o nounset
    unset -v \
        __kvar_color_mode \
        __kvar_mcfly \
        __kvar_nounset \
        __kvar_shell
    return 0
}

#!/bin/sh

_koopa_alias_glances() {
    # """
    # glances alias.
    # @note Updated 2023-03-11.
    #
    # The '--theme-white' setting only works when the background is exactly
    # white. Otherwise, need to use '9' hotkey.
    #
    # @seealso
    # - https://github.com/nicolargo/glances/issues/976
    # """
    case "$(_koopa_color_mode)" in
        'light')
            set -- '--theme-white' "$@"
            ;;
    esac
    glances \
        --config "${HOME}/.config/glances/glances.conf" \
        "$@"
    return 0
}

#!/bin/sh

koopa_alias_glances() {
    # """
    # glances alias.
    # @note Updated 2022-11-15.
    #
    # @seealso
    # - https://github.com/nicolargo/glances/issues/976
    # """
    local color_mode
    color_mode="$(koopa_color_mode)"
    case "$color_mode" in
        'light')
            set -- '--theme-white' "$@"
            ;;
    esac
    glances \
        --config "${HOME}/.config/glances/glances.conf" \
        "$@"
    return 0
}

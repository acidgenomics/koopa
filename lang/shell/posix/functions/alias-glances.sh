#!/bin/sh

koopa_alias_glances() {
    # """
    # glances alias.
    # @note Updated 2022-07-26.
    #
    # @seealso
    # - https://github.com/nicolargo/glances/issues/976
    # """
    local color_mode
    color_mode="$(koopa_color_mode)"
    case "$color_mode" in
        'dark')
            glances "$@"
            ;;
        'light')
            glances --light --theme-white "$@"
            ;;
    esac
    return 0
}

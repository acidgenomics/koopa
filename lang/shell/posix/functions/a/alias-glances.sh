#!/bin/sh

_koopa_alias_glances() {
    # """
    # glances alias.
    # @note Updated 2023-03-11.
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

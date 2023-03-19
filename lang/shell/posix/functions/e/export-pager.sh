#!/bin/sh

_koopa_export_pager() {
    # """
    # Export 'PAGER' variable.
    # @note Updated 2023-03-11.
    #
    # @seealso
    # - 'tldr --pager' (Rust tealdeer) requires the '-R' flag to be set here,
    #   otherwise will return without proper escape code handling.
    # """
    [ -n "${PAGER:-}" ] && return 0
    __kvar_less="$(_koopa_bin_prefix)/less"
    if [ -x "$__kvar_less" ]
    then
        export PAGER="${__kvar_less} -R"
    fi
    unset -v __kvar_less
    return 0
}

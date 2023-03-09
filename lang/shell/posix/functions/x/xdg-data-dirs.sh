#!/bin/sh

_koopa_xdg_data_dirs() {
    # """
    # XDG data dirs.
    # @note Updated 2022-04-08.
    # """
    local x
    x="${XDG_DATA_DIRS:-}"
    if [ -z "$x" ]
    then
        x='/usr/local/share:/usr/share'
    fi
    _koopa_print "$x"
    return 0
}

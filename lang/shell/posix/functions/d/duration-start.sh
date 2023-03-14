#!/bin/sh

_koopa_duration_start() {
    # """
    # Start activation duration timer.
    # @note Updated 2023-03-11.
    # """
    __kvar_date="$(_koopa_bin_prefix)/gdate"
    if [ ! -x "$__kvar_date" ]
    then
        unset -v __kvar_date
        return 0
    fi
    KOOPA_DURATION_START="$("$__kvar_date" -u '+%s%3N')"
    export KOOPA_DURATION_START
    unset -v __kvar_date
    return 0
}

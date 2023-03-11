#!/bin/sh

_koopa_duration_stop() {
    # """
    # Stop activation duration timer.
    # @note Updated 2023-03-11.
    # """
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    __kvar_bc="${__kvar_bin_prefix}/gbc"
    __kvar_date="${__kvar_bin_prefix}/gdate"
    unset -v __kvar_bin_prefix
    if [ ! -x "$__kvar_bc" ] || [ ! -x "$__kvar_date" ]
    then
        unset -v __kvar_bc __kvar_date
        return 0
    fi
    __kvar_key="${1:-}"
    if [ -z "$__kvar_key" ]
    then
        __kvar_key='duration'
    else
        __kvar_key="[${__kvar_key}] duration"
    fi
    __kvar_start="${KOOPA_DURATION_START:?}"
    __kvar_stop="$("$__kvar_date" -u '+%s%3N')"
    __kvar_duration="$( \
        _koopa_print "${__kvar_stop}-${__kvar_start}" \
        | "$__kvar_bc" \
    )"
    [ -n "$__kvar_duration" ] || return 1
    _koopa_dl "$__kvar_key" "${__kvar_duration} ms"
    unset -v \
        KOOPA_DURATION_START \
        __kvar_bc \
        __kvar_date \
        __kvar_duration \
        __kvar_start \
        __kvar_stop
    return 0
}

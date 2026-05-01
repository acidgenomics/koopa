#!/usr/bin/env zsh

_koopa_duration_stop() {
    local bin_prefix
    bin_prefix="$(_koopa_bin_prefix)"
    local bc
    bc="${bin_prefix}/gbc"
    local date
    date="${bin_prefix}/gdate"
    if [[ ! -x "$bc" ]] || [[ ! -x "$date" ]]
    then
        return 0
    fi
    local key
    key="${1:-}"
    if [[ -z "$key" ]]
    then
        key='duration'
    else
        key="[${key}] duration"
    fi
    local start
    start="${KOOPA_DURATION_START:?}"
    local stop
    stop="$("$date" -u '+%s%3N')"
    local duration
    duration="$( \
        _koopa_print "${stop}-${start}" \
        | "$bc" \
    )"
    [[ -n "$duration" ]] || return 1
    _koopa_print "${key}: ${duration} ms"
    unset -v KOOPA_DURATION_START
    return 0
}

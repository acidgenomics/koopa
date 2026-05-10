#!/usr/bin/env bash

_koopa_duration_start() {
    local date
    date="$(_koopa_bin_prefix)/gdate"
    if [[ ! -x "$date" ]]
    then
        return 0
    fi
    KOOPA_DURATION_START="$("$date" -u '+%s%3N')"
    export KOOPA_DURATION_START
    return 0
}

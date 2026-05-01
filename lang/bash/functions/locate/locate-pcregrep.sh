#!/usr/bin/env bash

_koopa_locate_pcregrep() {
    _koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2grep' \
        "$@"
}

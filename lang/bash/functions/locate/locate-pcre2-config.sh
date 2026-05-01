#!/usr/bin/env bash

_koopa_locate_pcre2_config() {
    _koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2-config' \
        "$@"
}

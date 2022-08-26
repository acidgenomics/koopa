#!/usr/bin/env bash

koopa_locate_pcre2_config() {
    koopa_locate_app \
        --app-name='pcre2' \
        --bin-name='pcre2-config'
        "$@" \
}

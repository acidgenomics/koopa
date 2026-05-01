#!/usr/bin/env bash

_koopa_locate_icu_config() {
    _koopa_locate_app \
        --app-name='icu4c' \
        --bin-name='icu-config' \
        "$@"
}

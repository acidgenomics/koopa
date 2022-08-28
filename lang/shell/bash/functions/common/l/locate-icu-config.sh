#!/usr/bin/env bash

koopa_locate_icu_config() {
    koopa_locate_app \
        --app-name='icu4c' \
        --bin-name='icu-config' \
        "$@"
}

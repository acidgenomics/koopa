#!/usr/bin/env bash

koopa_uninstall_icu4c() {
    koopa_uninstall_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

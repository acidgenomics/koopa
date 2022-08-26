#!/usr/bin/env bash

koopa_locate_kallisto() {
    koopa_locate_app \
        --app-name='kallisto' \
        --bin-name='kallisto'
        "$@" \
}

#!/usr/bin/env bash

koopa_locate_prefetch() {
    koopa_locate_app \
        --app-name='sratoolkit' \
        --bin-name='prefetch' \
        "$@"
}

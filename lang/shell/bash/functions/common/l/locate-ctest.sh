#!/usr/bin/env bash

koopa_locate_ctest() {
    koopa_locate_app \
        --app-name='cmake' \
        --bin-name='ctest' \
        "$@"
}

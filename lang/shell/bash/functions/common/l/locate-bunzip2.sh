#!/usr/bin/env bash

koopa_locate_bunzip2() {
    koopa_locate_app \
        --app-name='bzip2' \
        --bin-name='bunzip2' \
        "$@"
}

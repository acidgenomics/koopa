#!/usr/bin/env bash

_koopa_locate_bunzip2() {
    _koopa_locate_app \
        --app-name='bzip2' \
        --bin-name='bunzip2' \
        "$@"
}

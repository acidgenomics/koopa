#!/usr/bin/env bash

_koopa_locate_whoami() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwhoami' \
        --system-bin-name='whoami' \
        "$@"
}

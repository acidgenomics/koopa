#!/usr/bin/env bash

koopa_locate_whoami() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gwhoami' \
        "$@"
}

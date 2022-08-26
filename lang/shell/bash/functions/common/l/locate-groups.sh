#!/usr/bin/env bash

koopa_locate_groups() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ggroups' \
        "$@"
}

#!/usr/bin/env bash

_koopa_locate_groups() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='ggroups' \
        --system-bin-name='groups' \
        "$@"
}

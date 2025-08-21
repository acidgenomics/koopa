#!/usr/bin/env bash

koopa_locate_system_python() {
    koopa_locate_app \
        --only-system \
        --system-bin-name='python3' \
        "$@"
}

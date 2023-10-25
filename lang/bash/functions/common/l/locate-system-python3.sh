#!/usr/bin/env bash

koopa_locate_system_python3() {
    koopa_locate_app \
        --only-system \
        --system-bin-name='python3' \
        "$@"
}

#!/usr/bin/env bash

koopa_locate_scp() {
    koopa_locate_app \
        --app-name='openssh' \
        --bin-name='scp' \
        "$@"
}

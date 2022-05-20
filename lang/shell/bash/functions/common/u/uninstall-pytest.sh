#!/usr/bin/env bash

koopa_uninstall_pytest() {
    koopa_uninstall_app \
        --name='pytest' \
        --unlink-in-bin='pytest' \
        "$@"
}

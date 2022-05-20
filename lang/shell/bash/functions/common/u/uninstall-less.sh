#!/usr/bin/env bash

koopa_uninstall_less() {
    koopa_uninstall_app \
        --name='autoconf' \
        --unlink-in-bin='less' \
        "$@"
}

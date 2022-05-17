#!/usr/bin/env bash

koopa_uninstall_apr() {
    koopa_uninstall_app \
        --name-fancy='Apache Portable Runtime (APR) library' \
        --name='apr' \
        "$@"
}

#!/usr/bin/env bash

koopa_uninstall_libxml2() {
    koopa_uninstall_app \
        --name='libxml2' \
        --unlink-in-bin='xml2-config' \
        "$@"
}

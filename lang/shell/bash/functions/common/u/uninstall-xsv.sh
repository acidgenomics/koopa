#!/usr/bin/env bash

koopa_uninstall_xsv() {
    koopa_uninstall_app \
        --unlink-in-bin='xsv' \
        --name='xsv' \
        "$@"
}

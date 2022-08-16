#!/usr/bin/env bash

koopa_install_xsv() {
    koopa_install_app \
        --link-in-bin='xsv' \
        --name='xsv' \
        "$@"
}

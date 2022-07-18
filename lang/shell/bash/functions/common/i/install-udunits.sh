#!/usr/bin/env bash

koopa_install_udunits() {
    koopa_install_app \
        --link-in-bin='udunits2' \
        --name='udunits' \
        "$@"
}

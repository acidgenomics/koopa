#!/usr/bin/env bash

koopa_uninstall_udunits() {
    koopa_uninstall_app \
        --name='udunits' \
        --unlink-in-bin='udunits2' \
        "$@"
}

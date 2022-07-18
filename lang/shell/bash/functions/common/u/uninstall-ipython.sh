#!/usr/bin/env bash

koopa_uninstall_ipython() {
    koopa_uninstall_app \
        --name='ipython' \
        --unlink-in-bin='ipython' \
        "$@"
}

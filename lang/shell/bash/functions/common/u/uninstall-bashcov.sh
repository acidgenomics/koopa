#!/usr/bin/env bash

koopa_uninstall_bashcov() {
    koopa_uninstall_app \
        --name='bashcov' \
        --unlink-in-bin='bashcov' \
        "$@"
}

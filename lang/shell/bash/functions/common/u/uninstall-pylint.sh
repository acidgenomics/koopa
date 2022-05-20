#!/usr/bin/env bash

koopa_uninstall_pylint() {
    koopa_uninstall_app \
        --name='pylint' \
        --unlink-in-bin='pylint' \
        "$@"
}

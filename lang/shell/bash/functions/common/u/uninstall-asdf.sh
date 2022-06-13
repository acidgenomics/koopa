#!/usr/bin/env bash

koopa_uninstall_asdf() {
    koopa_uninstall_app \
        --name='asdf' \
        --unlink-in-bin='asdf' \
        "$@"
}

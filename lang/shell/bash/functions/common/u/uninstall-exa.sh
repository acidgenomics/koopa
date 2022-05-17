#!/usr/bin/env bash

koopa_uninstall_exa() {
    koopa_uninstall_app \
        --name='exa' \
        --unlink-in-bin='exa' \
        "$@"
}

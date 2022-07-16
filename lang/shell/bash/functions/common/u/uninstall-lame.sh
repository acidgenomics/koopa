#!/usr/bin/env bash

koopa_uninstall_lame() {
    koopa_uninstall_app \
        --name='lame' \
        --unlink-in-bin='lame' \
        "$@"
}

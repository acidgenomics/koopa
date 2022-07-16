#!/usr/bin/env bash

koopa_uninstall_cmake() {
    koopa_uninstall_app \
        --name='cmake' \
        --unlink-in-bin='cmake' \
        "$@"
}

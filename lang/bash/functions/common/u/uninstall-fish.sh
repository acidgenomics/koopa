#!/usr/bin/env bash

# NOTE Consider resetting default shell here, if necessary.

koopa_uninstall_fish() {
    koopa_uninstall_app \
        --name='fish' \
        "$@"
}

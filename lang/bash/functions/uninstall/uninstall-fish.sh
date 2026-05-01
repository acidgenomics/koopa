#!/usr/bin/env bash

# NOTE Consider resetting default shell here, if necessary.

_koopa_uninstall_fish() {
    _koopa_uninstall_app \
        --name='fish' \
        "$@"
}

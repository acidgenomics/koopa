#!/usr/bin/env bash

# NOTE This can cause shell to error when uninstalling current linked version.

_koopa_uninstall_bash() {
    _koopa_uninstall_app \
        --name='bash' \
        "$@"
}

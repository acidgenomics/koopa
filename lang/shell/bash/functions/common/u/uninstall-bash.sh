#!/usr/bin/env bash

# NOTE This can cause shell to error when uninstalling current linked version.

koopa_uninstall_bash() {
    koopa_uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        --unlink-in-bin='bash' \
        "$@"
}

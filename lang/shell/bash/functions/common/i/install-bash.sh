#!/usr/bin/env bash

# NOTE This can cause shell to error when reinstalling current linked version.

koopa_install_bash() {
    koopa_install_app \
        --link-in-bin='bin/bash' \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

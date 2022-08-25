#!/usr/bin/env bash

koopa_install_bash() {
    # """
    # This can cause shell to hang when reinstalling current version.
    # """
    koopa_install_app \
        --name='bash' \
        "$@"
}

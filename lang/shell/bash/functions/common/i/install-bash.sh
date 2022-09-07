#!/usr/bin/env bash

# FIXME Need to configure '/etc/shells' for shared install.

koopa_install_bash() {
    # """
    # This can cause shell to hang when reinstalling current version.
    # """
    koopa_install_app \
        --name='bash' \
        "$@"
}

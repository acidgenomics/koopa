#!/usr/bin/env bash

# NOTE This can cause shell to error when reinstalling current linked version.

koopa_install_bash() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/bash' \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

# NOTE This can cause shell to error when uninstalling current linked version.

koopa_uninstall_bash() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        --unlink-in-bin='bash' \
        "$@"
}

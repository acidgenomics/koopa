#!/usr/bin/env bash

koopa_install_bat() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/bat' \
        --name='bat' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_bat() { # {{{3
    koopa_uninstall_app \
        --name='bat' \
        --unlink-in-bin='bat' \
        "$@"
}

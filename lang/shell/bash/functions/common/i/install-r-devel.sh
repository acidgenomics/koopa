#!/usr/bin/env bash

koopa_install_r_devel() {
    # """
    # The 'R-devel' link is handled inside the installer script.
    # """
    koopa_install_app \
        --installer='r' \
        --name-fancy='R-devel' \
        --name='r-devel' \
        "$@"
}

#!/bin/sh
# shellcheck disable=all

koopa_opensuse_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='opensuse' \
        --system \
        "$@"
}

koopa_opensuse_locate_zypper() {
    koopa_locate_app '/usr/bin/zypper'
}

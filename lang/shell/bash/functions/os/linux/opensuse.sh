#!/bin/sh
# shellcheck disable=all
koopa_opensuse_install_base_system() {
    koopa_install_app \
        --name-fancy='openSUSE base system' \
        --name='base-system' \
        --platform='opensuse' \
        --system \
        "$@"
}
koopa_opensuse_locate_zypper() {
    koopa_locate_app '/usr/bin/zypper'
}

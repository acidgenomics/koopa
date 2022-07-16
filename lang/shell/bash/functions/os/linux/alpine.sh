#!/bin/sh
# shellcheck disable=all

koopa_alpine_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='alpine' \
        --system \
        "$@"
}

koopa_alpine_install_system_glibc() {
    koopa_install_app \
        --name='glibc' \
        --platform='alpine' \
        --system \
        --version='2.30-r0' \
        "$@"
}

koopa_alpine_locate_apk() {
    koopa_locate_app '/sbin/apk'
}

koopa_alpine_locate_localedef() {
    koopa_locate_app '/usr/glibc-compat/bin/localedef'
}

#!/usr/bin/env bash

_koopa_debian_locate_dpkg_reconfigure() {
    _koopa_locate_app \
        '/usr/sbin/dpkg-reconfigure' \
        "$@"
}

#!/usr/bin/env bash

koopa_alpine_locate_apk() {
    koopa_locate_app '/sbin/apk'
}

koopa_alpine_locate_localedef() {
    koopa_locate_app '/usr/glibc-compat/bin/localedef'
}

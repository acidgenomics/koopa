#!/usr/bin/env bash

koopa_debian_locate_locale_gen() {
    koopa_locate_app \
        '/usr/sbin/locale-gen' \
        "$@"
}

#!/usr/bin/env bash

_koopa_debian_locate_locale_gen() {
    _koopa_locate_app \
        '/usr/sbin/locale-gen' \
        "$@"
}

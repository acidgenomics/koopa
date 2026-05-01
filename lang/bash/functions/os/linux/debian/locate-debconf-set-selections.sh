#!/usr/bin/env bash

_koopa_debian_locate_debconf_set_selections() {
    _koopa_locate_app \
        '/usr/bin/debconf-set-selections' \
        "$@"
}

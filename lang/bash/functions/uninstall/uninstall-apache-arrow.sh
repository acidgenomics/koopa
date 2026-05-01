#!/usr/bin/env bash

_koopa_uninstall_apache_arrow() {
    _koopa_uninstall_app \
        --name='apache-arrow' \
        "$@"
}

#!/usr/bin/env bash

_koopa_fedora_locate_dnf() {
    _koopa_locate_app \
        '/usr/bin/dnf' \
        "$@"
}

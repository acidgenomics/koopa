#!/usr/bin/env bash

_koopa_fedora_locate_rpm() {
    _koopa_locate_app \
        '/usr/bin/rpm' \
        "$@"
}

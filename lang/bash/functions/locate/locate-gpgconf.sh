#!/usr/bin/env bash

_koopa_locate_gpgconf() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpgconf' \
        "$@"
}

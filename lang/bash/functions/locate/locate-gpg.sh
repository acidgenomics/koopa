#!/usr/bin/env bash

_koopa_locate_gpg() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg' \
        "$@"
}

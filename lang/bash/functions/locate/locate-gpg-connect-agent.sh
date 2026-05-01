#!/usr/bin/env bash

_koopa_locate_gpg_connect_agent() {
    _koopa_locate_app \
        --app-name='gnupg' \
        --bin-name='gpg-connect-agent' \
        "$@"
}

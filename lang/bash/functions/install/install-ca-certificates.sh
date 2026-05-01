#!/usr/bin/env bash

_koopa_install_ca_certificates() {
    _koopa_install_app \
        --name='ca-certificates' \
        "$@"
}

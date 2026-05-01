#!/usr/bin/env bash

_koopa_uninstall_ca_certificates() {
    _koopa_uninstall_app \
        --name='ca-certificates' \
        "$@"
}

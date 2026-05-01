#!/usr/bin/env bash

_koopa_fedora_uninstall_system_oracle_instant_client() {
    _koopa_uninstall_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

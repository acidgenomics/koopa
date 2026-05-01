#!/usr/bin/env bash

_koopa_fedora_install_system_oracle_instant_client() {
    _koopa_assert_is_arm64
    _koopa_install_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

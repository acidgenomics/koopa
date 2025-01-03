#!/usr/bin/env bash

koopa_fedora_install_system_oracle_instant_client() {
    koopa_assert_is_arm64
    koopa_install_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

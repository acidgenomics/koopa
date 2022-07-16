#!/usr/bin/env bash

koopa_fedora_uninstall_system_oracle_instant_client() {
    koopa_uninstall_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

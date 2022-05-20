#!/usr/bin/env bash

koopa_fedora_uninstall_oracle_instant_client() {
    koopa_uninstall_app \
        --name-fancy='Oracle Instant Client' \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

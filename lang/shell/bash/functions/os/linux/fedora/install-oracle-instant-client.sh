#!/usr/bin/env bash

koopa_fedora_install_oracle_instant_client() {
    koopa_install_app \
        --name-fancy='Oracle Instant Client' \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

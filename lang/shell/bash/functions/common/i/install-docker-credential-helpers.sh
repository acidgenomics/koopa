#!/usr/bin/env bash

koopa_install_docker_credential_helpers() {
    koopa_install_app \
        --name='docker-credential-helpers' \
        "$@"
}

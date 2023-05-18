#!/usr/bin/env bash

koopa_uninstall_docker_credential_helpers() {
    koopa_uninstall_app \
        --name='docker-credential-helpers' \
        "$@"
}

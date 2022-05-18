#!/usr/bin/env bash

koopa_linux_uninstall_docker_credential_pass() {
    koopa_uninstall_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        --unlink-in-bin='docker-credential-pass' \
        "$@"
}

#!/usr/bin/env bash

# FIXME Can we version pin this to 0.6.4?
# https://github.com/docker/docker-credential-helpers

koopa_linux_install_docker_credential_pass() {
    koopa_install_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

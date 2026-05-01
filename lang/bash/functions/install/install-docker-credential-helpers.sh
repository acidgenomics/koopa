#!/usr/bin/env bash

_koopa_install_docker_credential_helpers() {
    _koopa_install_app \
        --name='docker-credential-helpers' \
        "$@"
}

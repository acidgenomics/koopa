#!/usr/bin/env bash

_koopa_uninstall_docker_credential_helpers() {
    _koopa_uninstall_app \
        --name='docker-credential-helpers' \
        "$@"
}

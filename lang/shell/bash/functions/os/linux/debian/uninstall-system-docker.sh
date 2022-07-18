#!/usr/bin/env bash

# FIXME Ensure we unlink in koopa bin.

koopa_debian_uninstall_system_docker() {
    koopa_uninstall_app \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

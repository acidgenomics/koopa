#!/usr/bin/env bash

# FIXME Ensure we unlink in koopa bin.

koopa_debian_uninstall_system_wine() {
    koopa_uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

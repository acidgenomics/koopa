#!/usr/bin/env bash

# FIXME Rework this using version pinning.

koopa_linux_install_cloudbiolinux() {
    koopa_install_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --platform='linux' \
        --version='latest' \
        "$@"
}

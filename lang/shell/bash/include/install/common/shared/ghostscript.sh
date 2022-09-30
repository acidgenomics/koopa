#!/usr/bin/env bash

# FIXME conda is dragging behind on this, so consider installing from source.

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='ghostscript' \
        "$@"
}

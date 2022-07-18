#!/usr/bin/env bash

koopa_install_hadolint() {
    koopa_install_app \
        --link-in-bin='hadolint' \
        --name='hadolint' \
        "$@"
}

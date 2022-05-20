#!/usr/bin/env bash

koopa_install_hadolint() {
    koopa_install_app \
        --link-in-bin='bin/hadolint' \
        --name='hadolint' \
        "$@"
}

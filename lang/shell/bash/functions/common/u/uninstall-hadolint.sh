#!/usr/bin/env bash

koopa_uninstall_hadolint() {
    koopa_uninstall_app \
        --name='hadolint' \
        --unlink-in-bin='hadolint' \
        "$@"
}

#!/usr/bin/env bash

# FIXME Consider hardening against unwanted flags here.

koopa_install_all_supported() {
    # """
    # Install all supported apps.
    # @note Updated 2023-10-13.
    # """
    koopa_install_shared_apps --all-supported "$@"
    return 0
}

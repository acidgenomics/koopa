#!/usr/bin/env bash

# FIXME Consider hardening against unwanted flags here.

# FIXME Need to rework this:
# koopa install all supported isn't picking up outdated apps
# correctly:
#   FAIL | node (18.18.0 != 20.9.0)

koopa_install_all_supported() {
    # """
    # Install all supported apps.
    # @note Updated 2023-10-13.
    # """
    koopa_install_shared_apps --all-supported "$@"
    return 0
}

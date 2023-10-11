#!/usr/bin/env bash

# FIXME Consider just building from source on aarch64.

koopa_install_star() {
    # > koopa_assert_is_not_aarch64
    # > koopa_install_app \
    # >     --installer='conda-package' \
    # >     --name='star' \
    # >     "$@"
    koopa_install_app \
        --name='star' \
        "$@"
}

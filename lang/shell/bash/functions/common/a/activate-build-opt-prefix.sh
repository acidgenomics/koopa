#!/usr/bin/env bash

# FIXME Rename and rethink this function.
# Consider retiring in favor of using '--build-only' flag instead.

koopa_activate_build_opt_prefix() {
    # """
    # Activate a build-only opt prefix.
    # @note Updated 2022-04-22.
    #
    # Useful for activation of 'cmake', 'make', 'pkg-config', etc.
    # """
    koopa_activate_opt_prefix --build-only "$@"
}

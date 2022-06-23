#!/usr/bin/env bash

koopa_activate_build_opt_prefix() {
    # """
    # Activate a build-only opt prefix.
    # @note Updated 2022-04-22.
    #
    # Useful for activation of 'cmake', 'make', 'pkg-config', etc.
    # """
    koopa_activate_opt_prefix --build-only "$@"
}

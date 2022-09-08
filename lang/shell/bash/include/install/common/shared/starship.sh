#!/usr/bin/env bash

main() {
    # """
    # CMake was added as a build dependency in 1.10.
    # """
    koopa_activate_build_opt_prefix 'cmake'
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='starship' \
        "$@"
}

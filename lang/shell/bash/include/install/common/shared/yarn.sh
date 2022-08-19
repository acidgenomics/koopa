#!/usr/bin/env bash

main() {
    # """
    # Currently running into yarn registry 'incorrect data check' errors.
    # This may be due to zlib? How to fix?
    # """
    # > koopa_activate_opt_prefix 'zlib'
    koopa_install_app_internal \
        --installer='node-package' \
        --name='yarn' \
        "$@"
}

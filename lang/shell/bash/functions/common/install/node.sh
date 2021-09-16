#!/usr/bin/env bash

# FIXME This will fail inside of hardened 'install_app()' call. Need to rethink.
koopa::configure_node() { # {{{1
    # """
    # Configure Node.js (and NPM).
    # @note Updated 2021-06-14.
    # @seealso
    # > npm config get prefix
    # """
    koopa:::configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

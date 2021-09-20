#!/usr/bin/env bash

koopa::configure_node() { # {{{1
    # """
    # Configure Node.js (and NPM).
    # @note Updated 2021-09-17.
    # @seealso
    # > npm config get prefix
    # """
    koopa:::configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        --which-app="$(koopa::locate_node)" \
        "$@"
}

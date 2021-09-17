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

# FIXME Add a Debian binary installer from NodeSource.
# https://github.com/nodesource/distributions/blob/master/README.md
# https://nodesource.com/

# Using Ubuntu
# > curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
# > sudo apt-get install -y nodejs

# Using Debian, as root
# > curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
# > apt-get install -y nodejs


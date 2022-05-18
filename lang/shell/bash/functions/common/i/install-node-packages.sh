#!/usr/bin/env bash

koopa_install_node_packages() {
    koopa_install_app_packages \
        --link-in-bin='bin/bash-language-server' \
        --link-in-bin='bin/gtop' \
        --link-in-bin='bin/npm' \
        --link-in-bin='bin/prettier' \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

#!/usr/bin/env bash

koopa_configure_node() {
    koopa_configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

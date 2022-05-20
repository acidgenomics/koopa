#!/usr/bin/env bash

koopa_npm_version() {
    # """
    # Node package manager (NPM) version.
    # @note Updated 2022-03-21.
    # """
    koopa_assert_has_no_args "$#"
    koopa_node_package_version 'npm'
}

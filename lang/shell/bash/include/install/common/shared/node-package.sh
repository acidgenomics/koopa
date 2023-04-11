#!/usr/bin/env bash

# FIXME Can we chance the cache / clean up here better?

main() {
    # """
    # Install Node.js package using npm.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # """
    local -A app dict
    app['node']="$(koopa_locate_node)"
    app['npm']="$(koopa_locate_npm)"
    koopa_assert_is_executable "${app[@]}"
    app['node']="$(koopa_realpath "${app['node']}")"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_add_to_path_start "$(koopa_dirname "${app['node']}")"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    "${app['npm']}" install \
        --location='global' \
        --no-audit \
        --no-fund \
        "${dict['name']}@${dict['version']}" \
        2>&1
    return 0
}

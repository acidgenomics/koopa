#!/usr/bin/env bash

main() {
    # """
    # Install Node.js package using npm.
    # @note Updated 2023-08-25.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # - https://github.com/Homebrew/brew/blob/master/Library/Homebrew/
    #     language/node.rb
    # """
    local -A app dict
    local -a install_args
    app['node']="$(koopa_locate_node)"
    app['npm']="$(koopa_locate_npm)"
    koopa_assert_is_executable "${app[@]}"
    app['node']="$(koopa_realpath "${app['node']}")"
    dict['cache_prefix']="$(koopa_tmp_dir)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_add_to_path_start "$(koopa_dirname "${app['node']}")"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    koopa_is_root && install_args+=('--unsafe-perm')
    install_args+=(
        '-ddd'
        '--build-from-source'
        "--cache=${dict['cache_prefix']}"
        '--global'
        '--no-audit'
        '--no-fund'
        "${dict['name']}@${dict['version']}"
        # Enable pass-in of additional plug-ins (e.g. for prettier).
        "$@"
    )
    koopa_dl 'npm install args' "${install_args[*]}"
    "${app['npm']}" install "${install_args[@]}" 2>&1
    koopa_rm "${dict['cache_prefix']}"
    return 0
}

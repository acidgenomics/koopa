#!/usr/bin/env bash

koopa_install_node_package() {
    # """
    # Install Node.js package using npm.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # - https://github.com/Homebrew/brew/blob/master/Library/Homebrew/
    #     language/node.rb
    # """
    local -A app dict
    local -a extra_pkgs install_args
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'node'
    app['node']="$(koopa_locate_node --realpath)"
    app['npm']="$(koopa_locate_npm)"
    koopa_assert_is_executable "${app[@]}"
    dict['cache_prefix']="$(koopa_tmp_dir)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-packages')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    koopa_is_root && install_args+=('--unsafe-perm')
    install_args+=(
        '--build-from-source'
        "--cache=${dict['cache_prefix']}"
        '--global'
        '--loglevel=silly' # -ddd
        '--no-audit'
        '--no-fund'
        "${dict['name']}@${dict['version']}"
    )
    if koopa_is_array_non_empty "${extra_pkgs[@]}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    koopa_dl 'npm install args' "${install_args[*]}"
    "${app['npm']}" install "${install_args[@]}" 2>&1
    koopa_rm "${dict['cache_prefix']}"
    return 0
}

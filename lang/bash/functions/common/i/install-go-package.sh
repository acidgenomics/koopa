#!/usr/bin/env bash

koopa_install_go_package() {
    # """
    # Install a Go package using 'go install'.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - go help install
    # """
    local -A app dict
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    export GOBIN="${dict['prefix']}/bin"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    koopa_print_env
    "${app['go']}" install "${dict['url']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

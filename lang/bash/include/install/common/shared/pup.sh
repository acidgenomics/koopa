#!/usr/bin/env bash

# FIXME Consider reworking our main go package installer to use the
# 'go install' approach used here instead.

main() {
    # """
    # Install pup.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://github.com/ericchiang/pup
    # - https://formulae.brew.sh/formula/pup
    # """
    local -A app dict
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="github.com/ericchiang/pup@v${dict['version']}"
    export GOBIN="${dict['prefix']}/bin"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    koopa_print_env
    "${app['go']}" install "${dict['url']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

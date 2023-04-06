#!/usr/bin/env bash

main() {
    # """
    # Install yq.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/yq.rb
    # - go help build
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['name']='yq'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/mikefarah/yq/archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['go']}" build \
        -o "${dict['prefix']}/bin/yq"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

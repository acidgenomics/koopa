#!/usr/bin/env bash

main() {
    # """
    # Install csvtk.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/shenwei356/csvtk
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/csvtk.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['name']='csvtk'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/shenwei356/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['ldflags']='-s -w'
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/${dict['name']}" \
        ./csvtk
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
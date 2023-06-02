#!/usr/bin/env bash

main() {
    # """
    # Install llama.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/llama.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/antonmedv/llama/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    dict['ldflags']='-s -w'
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/${dict['name']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

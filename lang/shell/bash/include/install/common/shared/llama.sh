#!/usr/bin/env bash

main() {
    # """
    # Install llama.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/llama.rb
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['name']='llama'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/antonmedv/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['ldflags']='-s -w'
    koopa_print_env
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/${dict['name']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

#!/usr/bin/env bash

main() {
    # """
    # Install llama.
    # @note Updated 2022-11-25.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/llama.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    declare -A app=(
        ['go']="$(koopa_locate_go)"
    )
    [[ -x "${app['go']}" ]] || return 1
    declare -A dict=(
        ['gopath']="$(koopa_init_dir 'go')"
        ['name']='llama'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/antonmedv/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    export GOPATH="${dict['gopath']}"
    dict['ldflags']='-s -w'
    koopa_print_env
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${dict['prefix']}/bin/${dict['name']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

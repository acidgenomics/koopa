#!/usr/bin/env bash

main() {
    # """
    # Install cheat.
    # @note Updated 2023-03-02.
    #
    # @seealso
    # - https://github.com/cheat/cheat/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/cheat.rb
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    [[ -x "${app['go']}" ]] || exit 1
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['name']='cheat'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/cheat/cheat/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['go']}" build \
        -mod 'vendor' \
        -o "${dict['prefix']}/bin/${dict['name']}" \
        './cmd/cheat'
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

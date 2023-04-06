#!/usr/bin/env bash

main() {
    # """
    # Install unibilium.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/unibilium.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'libtool' 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['name']='unibilium'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/neovim/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}"
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}

#!/usr/bin/env bash

# NOTE Consider adding support for node and rust in a future update.

main() {
    # """
    # Install tree-sitter.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/tree-sitter.rb
    # """
    local app dict
    koopa_activate_app --build-only 'make' 'pkg-config'
    local -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['name']='tree-sitter'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" AMALGAMATED=1
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}

#!/usr/bin/env bash

main() {
    # """
    # Install libtermkey.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #     Formula/libtermkey.rb
    # """
    local app dict
    koopa_activate_build_opt_prefix 'libtool' 'pkg-config'
    koopa_activate_opt_prefix 'ncurses' 'unibilium'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='libtermkey'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.leonerd.org.uk/code/\
${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['make']}" PREFIX="${dict['prefix']}"
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}

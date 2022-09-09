#!/usr/bin/env bash

main() {
    # """
    # Install convmv.
    # @note Updated 2022-08-27.
    #
    # @seealso
    # - https://www.j3e.de/linux/convmv/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/convmv.rb
    # """
    local app dict
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']='convmv'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.j3e.de/linux/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}

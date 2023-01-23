#!/usr/bin/env bash

# FIXME This doesn't build successfully on macOS 13.1 with latest Xcode CLT.

main() {
    # """
    # Install trash.
    # @note Updated 2023-01-19.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/trash.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/ali-rantakari/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" VERBOSE=1
    "${app['make']}" VERBOSE=1 'docs'
    koopa_cp 'trash' \
        --target-directory="${dict['prefix']}/bin"
    koopa_cp 'trash.1' \
        --target-directory="${dict['prefix']}/share/man/man1"
    return 0
}

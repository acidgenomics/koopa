#!/usr/bin/env bash

main() {
    # """
    # Install tree.
    # @note Updated 2024-06-12.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/tree.html
    # - https://gist.github.com/fscm/9eee2784f101f21515d66321180aef0f
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Old-Man-Programmer/tree/archive/\
refs/tags/${dict['version']}.tgz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}"
    "${app['make']}" \
        PREFIX="${dict['prefix']}" \
        MANDIR="${dict['prefix']}/share/man" \
        install
    return 0
}

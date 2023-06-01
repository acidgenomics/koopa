#!/usr/bin/env bash

main() {
    # """
    # Install libvterm.
    # @note Updated 2023-06-01.
    #
    # @seealso
    #- https://github.com/Homebrew/homebrew-core/blob/HEAD/
    #    Formula/libvterm.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'libtool' 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='libvterm'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="http://www.leonerd.org.uk/code/libvterm/\
libvterm-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" install PREFIX="${dict['prefix']}"
    return 0
}

#!/usr/bin/env bash

# FIXME pkg-config isn't set up correctly:
# prefix=/opt/koopa/app/c-ares/1.34.4
# exec_prefix=${prefix}//opt/koopa/app/c-ares/1.34.4/bin
# libdir=${prefix}//opt/koopa/app/c-ares/1.34.4/lib
# includedir=${prefix}//opt/koopa/app/c-ares/1.34.4/include

main() {
    # """
    # Install c-ares.
    # @note Updated 2025-03-08.
    #
    # @seealso
    # - https://c-ares.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/c-ares.rb
    # """
    local -A dict
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/c-ares/c-ares/releases/download/\
v${dict['version']}/c-ares-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build \
        --bin-dir='bin' \
        --include-dir='include' \
        --lib-dir='lib' \
        --prefix="${dict['prefix']}"
    return 0
}

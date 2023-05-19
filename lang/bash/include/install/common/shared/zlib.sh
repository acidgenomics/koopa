#!/usr/bin/env bash

main() {
    # """
    # Install zlib.
    # @note Updated 2023-04-12.
    #
    # @seealso
    # - https://www.zlib.net/
    # - https://github.com/conda-forge/zlib-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zlib.rb
    # - https://github.com/archlinux/svntogit-packages/blob/master/zlib/
    #     trunk/PKGBUILD
    # """
    local -A dict
    local -a conf_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=("--prefix=${dict['prefix']}")
    dict['url']="https://www.zlib.net/zlib-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}

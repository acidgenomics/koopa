#!/usr/bin/env bash

# NOTE Consider tightening config for arpack, openblas, and superlu.

main() {
    # """
    # Install Armadillo.
    # @note Updated 2023-10-17.
    #
    # @seealso
    # - http://arma.sourceforge.net/download.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/armadillo.rb
    # - https://git.alpinelinux.org/aports/tree/community/armadillo/APKBUILD
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib' 'hdf5'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=('-DALLOW_OPENBLAS_MACOS=ON')
    dict['url']="http://sourceforge.net/projects/arma/files/\
armadillo-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

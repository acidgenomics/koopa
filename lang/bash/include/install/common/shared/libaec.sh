#!/usr/bin/env bash

main() {
    # """
    # Install libaec.
    # @note Updated 2023-09-29.
    #
    # @seealso
    # - https://gitlab.dkrz.de/k202009/libaec/
    # - https://gitlab.dkrz.de/k202009/libaec/-/blob/master/INSTALL.md
    # - https://github.com/MathisRosenhauer/libaec/
    # - https://formulae.brew.sh/formula/libaec/
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://gitlab.dkrz.de/k202009/libaec/-/archive/\
v${dict['version']}/libaec-v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    # Delete legacy 'aec' from bin.
    dict['bin_prefix']="$(koopa_bin_prefix)"
    koopa_rm "${dict['bin_prefix']}/aec"
    return 0
}

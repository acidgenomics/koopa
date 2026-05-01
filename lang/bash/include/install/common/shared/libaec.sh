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
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}"
    # Delete legacy 'aec' from bin.
    dict['bin_prefix']="$(_koopa_bin_prefix)"
    _koopa_rm "${dict['bin_prefix']}/aec"
    return 0
}

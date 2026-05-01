#!/usr/bin/env bash

main() {
    # """
    # Install ninja.
    # @note Updated 2025-08-21.
    #
    # @seealso
    # - https://github.com/ninja-build/ninja
    # - https://github.com/ninja-build/ninja/wiki
    # """
    local -A app dict
    _koopa_activate_app --build-only 'python'
    app['python']="$(_koopa_locate_python --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/ninja-build/ninja/archive/refs/\
tags/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    "${app['python']}" ./configure.py --bootstrap
    _koopa_cp --target-directory="${dict['prefix']}/bin" 'ninja'
    return 0
}

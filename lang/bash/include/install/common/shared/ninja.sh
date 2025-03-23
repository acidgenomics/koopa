#!/usr/bin/env bash

main() {
    # """
    # Install ninja.
    # @note Updated 2023-06-12.
    #
    # @seealso
    # - https://github.com/ninja-build/ninja
    # - https://github.com/ninja-build/ninja/wiki
    # """
    local -A app dict
    koopa_activate_app --build-only 'python3.12'
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/ninja-build/ninja/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "${app['python']}" ./configure.py --bootstrap
    koopa_cp --target-directory="${dict['prefix']}/bin" 'ninja'
    return 0
}

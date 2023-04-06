#!/usr/bin/env bash

main() {
    # """
    # Install ninja.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/ninja-build/ninja
    # - https://github.com/ninja-build/ninja/wiki
    # """
    local -A app dict
    koopa_activate_app --build-only 'python3.11'
    app['python']="$(koopa_locate_python311 --realpath)"
    [[ -x "${app['python']}" ]] || exit 1
    dict['name']='ninja'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/ninja-build/ninja/archive/refs/\
tags/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    "${app['python']}" ./configure.py --bootstrap
    koopa_cp --target-directory="${dict['prefix']}/bin" 'ninja'
    return 0
}

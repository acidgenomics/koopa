#!/usr/bin/env bash

main() {
    # """
    # Install ninja.
    # @note Updated 2022-09-30.
    #
    # @seealso
    # - https://github.com/ninja-build/ninja
    # - https://github.com/ninja-build/ninja/wiki
    # """
    local app dict
    koopa_activate_build_opt_prefix 'python'
    declare -A app=(
        ['python']="$(koopa_locate_python)"
    )
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['name']='ninja'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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

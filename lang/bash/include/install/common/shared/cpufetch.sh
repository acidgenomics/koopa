#!/usr/bin/env bash

main() {
    # """
    # Install cpufetch.
    # @note Updated 2023-06-01.
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='cpufetch'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Dr-Noob/cpufetch/archive/refs/\
tags/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    # Installer doesn't currently support 'configure' script.
    PREFIX="${dict['prefix']}" "${app['make']}" --jobs="${dict['jobs']}"
    # The 'make install' step is currently problematic on macOS.
    # > PREFIX="${dict['prefix']}" "${app['make']}" install
    koopa_cp --target-directory="${dict['prefix']}/bin" 'cpufetch'
    koopa_cp --target-directory="${dict['prefix']}/man/man1" 'cpufetch.1'
    return 0
}

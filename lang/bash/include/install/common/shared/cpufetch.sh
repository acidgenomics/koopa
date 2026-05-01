#!/usr/bin/env bash

main() {
    # """
    # Install cpufetch.
    # @note Updated 2023-06-12.
    # """
    local -A app dict
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/Dr-Noob/cpufetch/archive/refs/\
tags/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    # Installer doesn't currently support 'configure' script.
    PREFIX="${dict['prefix']}" "${app['make']}" --jobs="${dict['jobs']}"
    # The 'make install' step is currently problematic on macOS.
    # > PREFIX="${dict['prefix']}" "${app['make']}" install
    _koopa_cp --target-directory="${dict['prefix']}/bin" 'cpufetch'
    _koopa_cp --target-directory="${dict['prefix']}/man/man1" 'cpufetch.1'
    return 0
}

#!/usr/bin/env bash

main() {
    # """
    # Install cpufetch.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='cpufetch'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/Dr-Noob/${dict['name']}/archive/refs/\
tags/${dict['file']}"
    # Need to fix build issue on macOS for 1.03.
    # https://github.com/Dr-Noob/cpufetch/issues/168
    case "${dict['version']}" in
        '1.03')
            dict['version']='2fc4896429c4605b57e5b4c1095657c28cb3a0c3'
            dict['file']="${dict['version']}.tar.gz"
            dict['url']="https://github.com/Dr-Noob/${dict['name']}/\
archive/${dict['file']}"
            ;;
    esac
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    # Installer doesn't currently support 'configure' script.
    PREFIX="${dict['prefix']}" "${app['make']}" --jobs="${dict['jobs']}"
    # The 'make install' step is currently problematic on macOS.
    # > PREFIX="${dict['prefix']}" "${app['make']}" install
    koopa_cp --target-directory="${dict['prefix']}/bin" 'cpufetch'
    koopa_cp --target-directory="${dict['prefix']}/man/man1" 'cpufetch.1'
    return 0
}
#!/usr/bin/env bash

main() {
    # """
    # Install htop.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'make'
    koopa_activate_app \
        'ncurses' \
        'python3.11'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='htop'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}-dev/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    ./autogen.sh
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-unicode'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # > "${app['make']}" check
    "${app['make']}" install
    return 0
}

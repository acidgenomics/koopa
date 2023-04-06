#!/usr/bin/env bash

main() {
    # """
    # Companion library to apr, the Apache Portable Runtime library.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     apr-util.rb
    # - https://bz.apache.org/bugzilla/show_bug.cgi?id=61379
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'make' \
        'pkg-config'
    koopa_activate_app \
        'apr' \
        'expat' \
        'openssl3'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='apr-util'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://archive.apache.org/dist/apr/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    dict['apr']="$(koopa_app_prefix 'apr')"
    dict['expat']="$(koopa_app_prefix 'expat')"
    dict['openssl']="$(koopa_app_prefix 'openssl3')"
    conf_args=(
        "--prefix=${dict['prefix']}"
        "--with-apr=${dict['apr']}/bin/apr-1-config"
        "--with-expat=${dict['expat']}"
        "--with-openssl=${dict['openssl']}"
        '--with-crypto'
        '--without-pgsql'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

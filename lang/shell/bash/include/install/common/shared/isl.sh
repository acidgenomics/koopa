#!/usr/bin/env bash

main() {
    # """
    # Install isl.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://libisl.sourceforge.io/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/isl.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'gmp'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gmp']="$(koopa_app_prefix 'gmp')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://libisl.sourceforge.io/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--with-gmp=system'
        "--with-gmp-prefix=${dict['gmp']}"
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

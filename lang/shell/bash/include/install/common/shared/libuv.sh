#!/usr/bin/env bash

# NOTE Consider adding support for 'sphinx-doc'.

main() {
    # """
    # Install libuv.
    # @note Updated 2023-06-07.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libuv.rb
    # - https://cran.r-project.org/web/packages/httpuv/index.html
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'm4' \
        'make' \
        'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='libuv'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    # This tries to locate 'glibtoolize'.
    ./autogen.sh
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

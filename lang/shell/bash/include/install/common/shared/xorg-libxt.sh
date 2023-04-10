#!/usr/bin/env bash

main() {
    # """
    # Install xorg-libxt.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxt.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app \
        'xorg-xorgproto' \
        'xorg-libpthread-stubs' \
        'xorg-libice' \
        'xorg-libsm' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb' \
        'xorg-libx11'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='libXt'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://www.x.org/archive/individual/lib/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-specs=no'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

#!/usr/bin/env bash

# NOTE Consider adding support for 'xorg-macros'.

main() {
    # """
    # Install xorg-libx11.
    # @note Updated 2023-03-27.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcb.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'make' \
        'pkg-config' \
        'sed'
    koopa_activate_app \
        'xorg-xorgproto' \
        'xorg-xtrans' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp' \
        'xorg-libxcb'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libX11'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://www.x.org/archive/individual/lib/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-unix-transport'
        '--enable-tcp-transport'
        '--enable-ipv6'
        '--enable-local-transport'
        '--enable-loadable-i18n'
        '--enable-xthreads'
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

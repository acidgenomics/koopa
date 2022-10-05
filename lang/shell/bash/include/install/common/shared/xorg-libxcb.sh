#!/usr/bin/env bash

main() {
    # """
    # Install libxcb.
    # @note Updated 2022-10-05.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libxcb.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix \
        'xorg-xorgproto' \
        'xorg-xcb-proto' \
        'xorg-libpthread-stubs' \
        'xorg-libxau' \
        'xorg-libxdmcp'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libxcb'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://xcb.freedesktop.org/dist/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--enable-dri3'
        '--enable-ge'
        '--enable-xevie'
        '--enable-xprint'
        '--enable-selinux'
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-devel-docs=no'
        '--with-doxygen=no'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

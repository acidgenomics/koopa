#!/usr/bin/env bash

main() {
    # """
    # Install pixman.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/macports/macports-ports/blob/master/graphics/
    #     libpixman/Portfile
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pixman.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://cairographics.org/releases/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-gtk'
        '--disable-silent-rules'
    )
    # Disable NEON intrinsic support on macOS.
    # - https://gitlab.freedesktop.org/pixman/pixman/-/issues/59
    # - https://gitlab.freedesktop.org/pixman/pixman/-/issues/69
    if koopa_is_macos
    then
        conf_args+=('--disable-arm-a64-neon')
    fi
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

#!/usr/bin/env bash

# Switch to libjpeg-turbo?

main() {
    # """
    # Install libtiff.
    # @note Updated 2022-08-16.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libtiff.rb
    # - https://gitlab.com/libtiff/libtiff/-/commit/
    #     b25618f6fcaf5b39f0a5b6be3ab2fb288cf7a75b
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libtiff.html
    # - https://github.com/opentoonz/opentoonz/issues/1566
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'libjpeg-turbo' 'zstd'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="tiff-${dict['version']}.tar.gz"
    dict['url']="http://download.osgeo.org/libtiff/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "tiff-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-lzma'
        '--disable-webp'
        '--enable-shared=yes'
        '--enable-static=yes'
        '--without-x'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

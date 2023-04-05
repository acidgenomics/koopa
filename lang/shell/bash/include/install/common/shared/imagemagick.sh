#!/usr/bin/env bash

# NOTE Don't include graphviz here, as it can cause conflicts with Rgraphviz
# package in R, which bundles a very old version (2.28.0) currently.

main() {
    # """
    # Install ImageMagick.
    # @note Updated 2023-03-26.
    #
    # Also consider requiring:
    # - ghostscript
    # - libheif
    # - liblqr
    # - libraw
    # - little-cms2
    # - openexr
    # - openjpeg
    # - perl
    # - webp
    #
    # If using clang on macOS, need to include libomp, or ensure that
    # use has run 'koopa install system r-openmp'.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     imagemagick.rb
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/libomp.rb
    # - https://imagemagick.org/script/install-source.php
    # - https://imagemagick.org/script/advanced-linux-installation.php
    # - https://download.imagemagick.org/ImageMagick/download/releases/
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    deps=(
        'zlib'
        'zstd'
        'bzip2'
        'xz'
        'freetype'
        'jpeg'
        'libpng'
        'libtiff'
        'libtool'
        'libxml2'
        'libzip'
        'fontconfig'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-libice'
        'xorg-libsm'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'xorg-libxt'
    )
    # Using system clang on macOS to avoid '-lopenmp' issues when building
    # R from source.
    if koopa_is_linux
    then
        # gcc deps: gmp, mpfr, mpc.
        deps+=('gcc')
    fi
    koopa_activate_app "${deps[@]}"
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['mmp_ver']="$(koopa_major_minor_patch_version "${dict['version']}")"
    dict['file']="ImageMagick-${dict['version']}.tar.xz"
    dict['url']="https://imagemagick.org/archive/releases/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "ImageMagick-${dict['mmp_ver']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--with-modules'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

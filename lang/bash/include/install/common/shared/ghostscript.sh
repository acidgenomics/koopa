#!/usr/bin/env bash

# Consider depending on: fontconfig, freetype, jbig2dec, jpeg-turbo, libidn,
# libpng, libtiff, little-cms2, openjpeg, expat, zlib

main() {
    # """
    # Install Ghostscript.
    # @note Updated 2023-04-10.
    #
    # @seealso
    # - https://github.com/ArtifexSoftware/ghostpdl-downloads
    # - https://github.com/conda-forge/ghostscript-feedstock/blob/
    #     main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/ghostscript.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    # e.g. '10.0.0' to '1000'.
    dict['version2']="$( \
            koopa_gsub \
                --fixed \
                --pattern='.'  \
                --replacement='' \
                "${dict['version']}" \
    )"
    conf_args=(
        # > '--with-system-libtiff'
        '--disable-compile-inits'
        '--disable-cups'
        '--disable-gtk'
        "--prefix=${dict['prefix']}"
        '--without-tesseract'
        '--without-x'
    )
    dict['url']="https://github.com/ArtifexSoftware/ghostpdl-downloads/\
releases/download/gs${dict['version2']}/ghostpdl-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" VERBOSE=1 so --jobs="${dict['jobs']}"
    "${app['make']}" install --jobs="${dict['jobs']}"
    "${app['make']}" install-so --jobs=1
    return 0
}

#!/usr/bin/env bash

# Consider depending on: fontconfig, freetype, jbig2dec, jpeg-turbo, libidn,
# libpng, libtiff, little-cms2, openjpeg, expat, zlib

main() {
    # """
    # Install Ghostscript.
    # @note Updated 2023-01-05.
    #
    # @seealso
    # - https://github.com/ArtifexSoftware/ghostpdl-downloads
    # - https://github.com/conda-forge/ghostscript-feedstock/blob/
    #     main/recipe/build.sh
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/ghostscript.rb
    # """
    local app conf_args dict
    koopa_activate_app --build-only 'pkg-config'
    declare -A app
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='ghostpdl'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    # e.g. '10.0.0' to '1000'.
    dict['version2']="$( \
            koopa_gsub \
                --fixed \
                --pattern='.'  \
                --replacement='' \
                "${dict['version']}" \
    )"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://github.com/ArtifexSoftware/${dict['name']}-downloads/\
releases/download/gs${dict['version2']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        # > '--with-system-libtiff'
        "--prefix=${dict['prefix']}"
        '--disable-compile-inits'
        '--disable-cups'
        '--disable-gtk'
        '--without-tesseract'
        '--without-x'
    )
    koopa_print_env
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" VERBOSE=1 so --jobs="${dict['jobs']}"
    "${app['make']}" install --jobs="${dict['jobs']}"
    "${app['make']}" install-so --jobs=1
    return 0
}

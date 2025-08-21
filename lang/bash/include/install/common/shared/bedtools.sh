#!/usr/bin/env bash

main() {
    # """
    # Install bedtools.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://bedtools.readthedocs.io/en/latest/content/faq.html
    # - https://github.com/arq5x/bedtools2
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/bedtools
    # - https://github.com/arq5x/bedtools2/issues/494
    # - https://github.com/arq5x/bedtools2/tree/master/src/utils/htslib
    # """
    local -A app dict
    local -a deps libs
    koopa_activate_app --build-only 'autoconf' 'automake' 'make'
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('curl' 'openssl' 'xz' 'zlib')
    koopa_activate_app "${deps[@]}"
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['make']="$(koopa_locate_make)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/arq5x/bedtools2/releases/download/\
v${dict['version']}/bedtools-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'bedtools'
    (
        koopa_cd 'bedtools/src/utils/htslib'
        # This is needed to provide compatibility with autoconf 2.69.
        "${app['sed']}" \
            -i.bak \
            '/AC_PROG_CC/a AC_CANONICAL_HOST\nAC_PROG_INSTALL' \
            'configure.ac'
        "${app['autoreconf']}" --force --install --verbose
        ./configure
    )
    libs+=(
        '-lbz2'
        '-lcrypto'
        '-lcurl'
        '-llzma'
        '-lssl'
        '-lz'
        "-L${dict['curl']}/lib"
        "-L${dict['openssl']}/lib"
        "-L${dict['xz']}/lib"
        "-L${dict['zlib']}/lib"
        "-Wl,-rpath,${dict['curl']}/lib"
        "-Wl,-rpath,${dict['openssl']}/lib"
        "-Wl,-rpath,${dict['xz']}/lib"
        "-Wl,-rpath,${dict['zlib']}/lib"
    )
    if ! koopa_is_macos
    then
        dict['bzip2']="$(koopa_app_prefix 'bzip2')"
        libs+=(
            "-L${dict['bzip2']}/lib"
            "-Wl,-rpath,${dict['bzip2']}/lib"
        )
    fi
    koopa_cd 'bedtools'
    koopa_print_env
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        LIBS="${libs[*]}" \
        VERBOSE=1 \
        install prefix="${dict['prefix']}"
    return 0
}

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
    _koopa_activate_app --build-only 'autoconf' 'automake' 'make'
    ! _koopa_is_macos && deps+=('bzip2')
    deps+=('curl' 'openssl' 'xz' 'zlib')
    _koopa_activate_app "${deps[@]}"
    app['autoreconf']="$(_koopa_locate_autoreconf)"
    app['make']="$(_koopa_locate_make)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['curl']="$(_koopa_app_prefix 'curl')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['openssl']="$(_koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(_koopa_app_prefix 'xz')"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/arq5x/bedtools2/releases/download/\
v${dict['version']}/bedtools-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'bedtools'
    (
        _koopa_cd 'bedtools/src/utils/htslib'
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
    if ! _koopa_is_macos
    then
        dict['bzip2']="$(_koopa_app_prefix 'bzip2')"
        libs+=(
            "-L${dict['bzip2']}/lib"
            "-Wl,-rpath,${dict['bzip2']}/lib"
        )
    fi
    _koopa_cd 'bedtools'
    _koopa_print_env
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        LIBS="${libs[*]}" \
        VERBOSE=1 \
        install prefix="${dict['prefix']}"
    return 0
}

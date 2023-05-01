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
    local -a libs
    koopa_activate_app --build-only 'autoconf' 'automake' 'make'
    koopa_activate_app 'bzip2' 'curl' 'xz' 'zlib'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['make']="$(koopa_locate_make)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['curl']="$(koopa_app_prefix 'curl')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['xz']="$(koopa_app_prefix 'xz')"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/arq5x/bedtools2/releases/download/\
v${dict['version']}/bedtools-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/bedtools2'
    koopa_print_env
    (
        koopa_cd 'src/utils/htslib'
        # This is needed to provide compatibility with autoconf 2.69.
        "${app['sed']}" \
            -i.bak \
            '/AC_PROG_CC/a AC_CANONICAL_HOST\nAC_PROG_INSTALL' \
            'configure.ac'
        "${app['autoreconf']}" -fiv
        ./configure
    )
    libs=(
        "-L${dict['bzip2']}/lib"
        "-L${dict['curl']}/lib"
        "-L${dict['xz']}/lib"
        "-L${dict['zlib']}/lib"
        "-Wl,-rpath,${dict['bzip2']}/lib"
        "-Wl,-rpath,${dict['curl']}/lib"
        "-Wl,-rpath,${dict['xz']}/lib"
        "-Wl,-rpath,${dict['zlib']}/lib"
    )
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        LIBS="${libs[*]}" \
        VERBOSE=1 \
        install prefix="${dict['prefix']}"
    return 0
}

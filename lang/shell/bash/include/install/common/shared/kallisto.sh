#!/usr/bin/env bash

main() {
    # """
    # Install kallisto.
    # @note updated 2023-05-01.
    #
    # @seealso
    # - https://github.com/pachterlab/kallisto
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/kallisto
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     kallisto.rb
    # - https://github.com/pachterlab/kallisto/issues/159
    # - https://github.com/pachterlab/kallisto/issues/160
    # - https://github.com/pachterlab/kallisto/issues/161
    # - https://github.com/pachterlab/kallisto/issues/303
    # """
    local -A app dict
    local -a cmake_args
    koopa_activate_app --build-only 'autoconf' 'automake' 'sed'
    koopa_activate_app 'hdf5' 'zlib'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['cmake']="$(koopa_locate_cmake)"
    app['make']="$(koopa_locate_cmake)"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DUSE_HDF5=ON'
        # Dependency paths -----------------------------------------------------
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
    dict['url']="https://github.com/pachterlab/kallisto/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    (
        koopa_cd 'src/ext/htslib'
        # This patch step is needed for autoconf 2.69 compatibility.
        # https://github.com/pachterlab/kallisto/issues/
        #   303#issuecomment-884612169
        "${app['sed']}" \
            -i.bak \
            '/AC_PROG_CC/a AC_CANONICAL_HOST\nAC_PROG_INSTALL' \
            'configure.ac'
        "${app['autoreconf']}" -fiv
    )
    koopa_cd 'src'
    export KOOPA_CPU_COUNT=1
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

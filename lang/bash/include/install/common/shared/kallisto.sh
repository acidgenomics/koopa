#!/usr/bin/env bash

# NOTE v0.50.0: Currently hitting a zlib config issue with bifrost.
# https://github.com/pachterlab/kallisto/issues/385

main() {
    # """
    # Install kallisto.
    # @note updated 2023-06-28.
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
    local -A app cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'autoconf' 'automake'
    koopa_activate_app 'bzip2' 'hdf5' 'xz' 'zlib'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(koopa_app_prefix 'bzip2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake['bzip2_include_dir']="${dict['bzip2']}/include"
    cmake['bzip2_libraries']="${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['bzip2_include_dir']}" \
        "${cmake['zlib_include_dir']}"
    koopa_assert_is_file \
        "${cmake['bzip2_libraries']}" \
        "${cmake['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DUSE_HDF5=ON'
        # Dependency paths -----------------------------------------------------
        "-DBZIP2_INCLUDE_DIR=${cmake['bzip2_include_dir']}"
        "-DBZIP2_LIBRARIES=${cmake['bzip2_libraries']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    dict['url']="https://github.com/pachterlab/kallisto/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    # This patch step is needed for autoconf 2.69 compatibility.
    # https://github.com/pachterlab/kallisto/issues/303#issuecomment-884612169
    (
        koopa_cd 'src/ext/htslib'
        "${app['sed']}" \
            -i.bak \
            '/AC_PROG_CC/a AC_CANONICAL_HOST\nAC_PROG_INSTALL' \
            'configure.ac'
        "${app['autoreconf']}" --force --install --verbose
        ./configure
    )
    koopa_cd 'src'
    export KOOPA_CPU_COUNT=1
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

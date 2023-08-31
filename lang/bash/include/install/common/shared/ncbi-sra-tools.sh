#!/usr/bin/env bash

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2023-08-31.
    #
    # Currently, we need to build sra-tools relative to a hard-coded path
    # ('../ncbi-vdb') to ncbi-vdb source code, to ensure that zlib and bzip2
    # headers get linked correctly. For reference, these are defined inside
    # the 'interfaces' subdirectory.
    #
    # CMake configuration will pick up Python Framework on macOS unless we
    # set the desired target manually.
    #
    # @seealso
    # - https://github.com/ncbi/sra-tools/wiki/
    # - https://github.com/ncbi/ngs-tools
    # - https://hpc.nih.gov/apps/sratoolkit.html
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/sra-tools
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/sratoolkit.rb
    # """
    local -A app cmake dict
    local -a build_deps cmake_args
    build_deps=('bison' 'flex' 'ncbi-vdb' 'python3.11')
    koopa_activate_app --build-only "${build_deps[@]}"
    app['python']="$(koopa_locate_python311 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['vdb']="$(koopa_app_prefix 'ncbi-vdb')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    export CFLAGS
    cmake['libxml2_include_dir']="${dict['libxml2']}/include"
    cmake['libxml2_libraries']="${dict['libxml2']}/lib/\
libxml2.${dict['shared_ext']}"
    cmake['python3_executable']="${app['python']}"
    cmake['vdb_bindir']="${dict['vdb']}/lib"
    cmake['vdb_incdir']="${dict['vdb']}/include"
    cmake['vdb_libdir']="${dict['vdb']}/lib"
    koopa_assert_is_dir \
        "${cmake['libxml2_include_dir']}" \
        "${cmake['vdb_bindir']}" \
        "${cmake['vdb_incdir']}" \
        "${cmake['vdb_libdir']}"
    koopa_assert_is_file \
        "${cmake['libxml2_libraries']}" \
        "${cmake['python3_executable']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DNO_JAVA=ON'
        # Dependency paths -----------------------------------------------------
        "-DLIBXML2_INCLUDE_DIR=${cmake['libxml2_include_dir']}"
        "-DLIBXML2_LIBRARIES=${cmake['libxml2_libraries']}"
        "-DPython3_EXECUTABLE=${cmake['python3_executable']}"
        "-DVDB_BINDIR=${cmake['vdb_bindir']}"
        "-DVDB_INCDIR=${cmake['vdb_incdir']}"
        "-DVDB_LIBDIR=${cmake['vdb_libdir']}"
    )
    dict['url']="https://github.com/ncbi/sra-tools/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    if koopa_is_root
    then
        # Disable creation of these files and directories:
        # - /etc/ncbi/
        # - /etc/profile.d/sra-tools.csh
        # - /etc/profile.d/sra-tools.sh
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'build/install.sh'
    fi
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

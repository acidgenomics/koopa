#!/usr/bin/env bash


# Minimal build reprex:
# https://github.com/ncbi/sra-tools/issues/937
# > cd ${TMPDIR}
# > git clone https://github.com/ncbi/ncbi-vdb.git
# > git clone https://github.com/ncbi/sra-tools.git
# > mkdir build
# > cd build
# > cmake -S "$(cd ../ncbi-vdb; pwd)" -B ncbi-vdb
# > cmake --build ncbi-vdb
 #> cmake -D VDB_LIBDIR="${PWD}/ncbi-vdb/lib" -D CMAKE_INSTALL_PREFIX="${PWD}/sratoolkit" -S "$(cd ../sra-tools; pwd)" -B sra-tools
# > cmake --build sra-tools --target install
# > ./sratoolkit/bin/prefetch --version

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2024-06-14.
    #
    # VDB is the database engine that all SRA tools use.
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
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/ncbi-vdb
    # """
    local -A app cmake dict
    local -a build_deps cmake_args deps
    build_deps+=('bison' 'flex' 'python3.12')
    deps+=('zlib' 'icu4c' 'libxml2' 'hdf5')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['temurin']="$(koopa_app_prefix 'temurin')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake['libxml2_include_dir']="${dict['libxml2']}/include"
    cmake['libxml2_libraries']="${dict['libxml2']}/lib/\
libxml2.${dict['shared_ext']}"
    cmake['python3_executable']="${app['python']}"
    koopa_assert_is_dir \
        "${cmake['libxml2_include_dir']}" \
        "${dict['temurin']}"
    koopa_assert_is_file \
        "${cmake['libxml2_libraries']}" \
        "${cmake['python3_executable']}"
    dict['vdb_url']="https://github.com/ncbi/ncbi-vdb/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['vdb_url']}" 'ncbi-vdb.tar.gz'
    koopa_extract 'ncbi-vdb.tar.gz' 'ncbi-vdb'
    dict['sra_url']="https://github.com/ncbi/sra-tools/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['sra_url']}" 'sra-tools.tar.gz'
    koopa_extract 'sra-tools.tar.gz' 'sra-tools'
    # Build ncbi-vdb ===========================================================
    koopa_append_cflags '-DH5_USE_110_API'
    export JAVA_HOME="${dict['temurin']}"
    cmake_args=(
        # > '-DLIBS_ONLY=ON'
        "-DPython3_EXECUTABLE=${cmake['python3_executable']}"
    )
    koopa_cd 'ncbi-vdb'
    if koopa_is_root
    then
        # Disable creation of these files:
        # - /etc/ncbi/
        # - /etc/profile.d/ncbi-vdb.csh
        # - /etc/profile.d/ncbi-vdb.sh
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'build/install-root.sh'
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'libs/kfg/install.sh'
    fi
    koopa_cmake_build --prefix='.' "${cmake_args[@]}"
    koopa_cd '..'
    # Build sra-tools ==========================================================
    dict['vdb']="$(koopa_realpath 'ncbi-vdb')"
    cmake['vdb_bindir']="${dict['vdb']}"
    cmake['vdb_libdir']="${dict['vdb']}/lib"
    cmake['vdb_incdir']="${dict['vdb']}/include"
    koopa_assert_is_dir \
        "${cmake['vdb_bindir']}" \
        "${cmake['vdb_incdir']}" \
        "${cmake['vdb_libdir']}"
    if koopa_is_macos
    then
        cmake['vdb_incdir']="${dict['vdb']}/interfaces"
    fi
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
    koopa_cd 'sra-tools'
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
    # If build fails, set '--jobs=1' here for better debugging info.
    koopa_cmake_build \
        --prefix="${dict['prefix']}" \
        "${cmake_args[@]}"
    return 0
}

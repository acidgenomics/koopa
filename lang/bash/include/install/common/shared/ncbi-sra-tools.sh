#!/usr/bin/env bash

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2024-06-14.
    #
    # VDB is the database engine that all SRA tools use.
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
    # - https://github.com/ncbi/sra-tools/issues/937
    # """
    local -A app cmake dict
    local -a build_deps cmake_args cmake_std_args deps
    build_deps+=('bison' 'flex' 'python3.12')
    deps+=('zlib' 'icu4c' 'libxml2' 'hdf5')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['cmake']="$(koopa_locate_cmake)"
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
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
    if koopa_is_root
    then
        # Disable creation of these files and directories:
        # - /etc/ncbi/
        # - /etc/profile.d/ncbi-vdb.csh
        # - /etc/profile.d/ncbi-vdb.sh
        # - /etc/profile.d/sra-tools.csh
        # - /etc/profile.d/sra-tools.sh
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'ncbi-vdb/build/install-root.sh'
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'ncbi-vdb/libs/kfg/install.sh'
        # shellcheck disable=SC2016
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='[ "$EUID" -eq 0 ]' \
            --replacement='[ "$EUID" -eq -1 ]' \
            'sra-tools/build/install.sh'
    fi
    readarray -t cmake_std_args <<< "$( \
        koopa_cmake_std_args --prefix="${dict['prefix']}" \
    )"
    # Build ncbi-vdb (without install) =========================================
    koopa_append_cflags '-DH5_USE_110_API'
    export JAVA_HOME="${dict['temurin']}"
    cmake_args=(
        "${cmake_std_args[@]}"
        "-DPython3_EXECUTABLE=${cmake['python3_executable']}"
    )
    "${app['cmake']}" \
        -B 'ncbi-vdb-build' \
        -S "$(koopa_realpath 'ncbi-vdb')" \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'ncbi-vdb-build' \
        --parallel "${dict['jobs']}"
    # Build and install sra-tools ==============================================
    cmake_args=(
        "-DLIBXML2_INCLUDE_DIR=${cmake['libxml2_include_dir']}"
        "-DLIBXML2_LIBRARIES=${cmake['libxml2_libraries']}"
        '-DNO_JAVA=ON'
        "-DPython3_EXECUTABLE=${cmake['python3_executable']}"
        "-DVDB_LIBDIR=$(koopa_realpath 'ncbi-vdb-build/lib')"
    )
    koopa_cd 'sra-tools'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

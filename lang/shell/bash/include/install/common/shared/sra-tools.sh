#!/usr/bin/env bash

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2022-08-12.
    #
    # Currently, we need to build sra-tools relative to a hard-coded path
    # ('../ncbi-vdb') to ncbi-vdb source code, to ensure that zlib and bzip2
    # headers get linked correctly. For reference, these are defined inside
    # the 'interfaces' subdirectory.
    #
    # CMake configuration will pick up Python Framework on macOS unless we
    # set the desired target manually.
    #
    # Linking to our bzip2 and zlib libraries is currently problematic,
    # and will result in build issues on Linux.
    #
    # @seealso
    # - https://github.com/ncbi/sra-tools/wiki/
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/ncbi/ngs-tools
    # - https://hpc.nih.gov/apps/sratoolkit.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/sratoolkit.rb
    # """
    local app deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    deps=()
    koopa_is_linux && deps+=('gcc')
    deps+=(
        'hdf5'
        'libxml2'
        'python'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    app['python']="$(koopa_realpath "${app['python']}")"
    declare -A dict=(
        [base_url]='https://github.com/ncbi'
        [hdf5]="$(koopa_app_prefix 'hdf5')"
        [java_home]="$(koopa_java_prefix)"
        [libxml2]="$(koopa_app_prefix 'libxml2')"
        [prefix]="${INSTALL_PREFIX:?}"
        [shared_ext]="$(koopa_shared_ext)"
        [version]="${INSTALL_VERSION:?}"
    )
    # Ensure we define Java location, otherwise install can hit warnings during
    # ngs-tools install.
    koopa_assert_is_dir "${dict['java_home']}"
    export JAVA_HOME="${dict['java_home']}"
    # Need to use HDF5 1.10 API.
    export CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    # Build NCBI VDB Software Development Kit (no install).
    (
        local cmake_args dict2
        declare -A dict2
        dict2['name']='ncbi-vdb'
        dict2['file']="${dict2['name']}-${dict['version']}.tar.gz"
        dict2['url']="${dict['base_url']}/${dict2['name']}/archive/refs/tags/\
${dict['version']}.tar.gz"
        koopa_download "${dict2['url']}" "${dict2['file']}"
        koopa_extract "${dict2['file']}"
        koopa_mv \
            "${dict2['name']}-${dict['version']}" \
            "${dict2['name']}-source"
        cmake_args=(
            "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
            "-DPython3_EXECUTABLE=${app['python']}"
            "-DHDF5_ROOT=${dict['hdf5']}"
            "-DLIBXML2_INCLUDE_DIR=${dict['libxml2']}/include"
            "-DLIBXML2_LIBRARY=${dict['libxml2']}/lib/libxml2.${dict['shared_ext']}"
        )
        "${app['cmake']}" \
            -S "${dict2['name']}-source" \
            -B "${dict2['name']}-build" \
            "${cmake_args[@]}"
        "${app['cmake']}" --build "${dict2['name']}-build"
    )
    dict['ncbi_vdb_build']="$( \
        koopa_realpath "ncbi-vdb-build" \
    )"
    dict['ncbi_vdb_source']="$( \
        koopa_realpath "ncbi-vdb-source" \
    )"
    # This step is currently needed to correctly link bzip2 and zlib.
    koopa_ln 'ncbi-vdb-source' 'ncbi-vdb'
    # Build and install NCBI SRA Toolkit.
    (
        local cmake_args dict2
        declare -A dict2
        dict2['name']='sra-tools'
        dict2['file']="${dict2['name']}-${dict['version']}.tar.gz"
        dict2['url']="${dict['base_url']}/${dict2['name']}/archive/refs/tags/\
${dict['version']}.tar.gz"
        koopa_download "${dict2['url']}" "${dict2['file']}"
        koopa_extract "${dict2['file']}"
        koopa_mv \
            "${dict2['name']}-${dict['version']}" \
            "${dict2['name']}-source"
        # Need to fix '/obj/ngs/ngs-java' path issue in 'CMakeLists.txt' file.
        # See related: https://github.com/ncbi/sra-tools/pull/664/files
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='/obj/ngs/ngs-java/' \
            --replacement='/ngs/ngs-java/' \
            "${dict2['name']}-source/ngs/ngs-java/CMakeLists.txt"
        cmake_args=(
            "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
            "-DPython3_EXECUTABLE=${app['python']}"
            "-DHDF5_ROOT=${dict['hdf5']}"
            "-DLIBXML2_INCLUDE_DIR=${dict['libxml2']}/include"
            "-DLIBXML2_LIBRARY=${dict['libxml2']}/lib/libxml2.${dict['shared_ext']}"
            "-DVDB_BINDIR=${dict['ncbi_vdb_build']}"
            "-DVDB_INCDIR=${dict['ncbi_vdb_source']}/interfaces"
            "-DVDB_LIBDIR=${dict['ncbi_vdb_build']}/lib"
        )
        "${app['cmake']}" \
            -S "${dict2['name']}-source" \
            -B "${dict2['name']}-build" \
            "${cmake_args[@]}"
        "${app['cmake']}" --build "${dict2['name']}-build"
        "${app['cmake']}" --install "${dict2['name']}-build"
    )
    return 0
}

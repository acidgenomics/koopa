#!/usr/bin/env bash

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2023-03-24.
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
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/ncbi/ngs-tools
    # - https://hpc.nih.gov/apps/sratoolkit.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/sratoolkit.rb
    # """
    local app deps dict shared_cmake_args
    koopa_assert_is_not_aarch64
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    deps=()
    # > koopa_is_linux && deps+=('gcc')
    deps+=(
        'bison'
        'flex'
        'python3.11'
    )
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['python']="$(koopa_locate_python311 --realpath)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        ['base_url']='https://github.com/ncbi'
        ['openjdk']="$(koopa_app_prefix 'openjdk')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['openjdk']}"
    # Ensure we define Java location, otherwise install can hit warnings during
    # ngs-tools install.
    export JAVA_HOME="${dict['openjdk']}"
    koopa_print_env
    shared_cmake_args=(
        # Standard CMake arguments ---------------------------------------------
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DCMAKE_VERBOSE_MAKEFILE=ON'
        # Dependency paths -----------------------------------------------------
        "-DPython3_EXECUTABLE=${app['python']}"
    )
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
        cmake_args=("${shared_cmake_args[@]}")
        koopa_dl 'CMake args' "${cmake_args[*]}"
        "${app['cmake']}" -LH \
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
        # See related: https://github.com/ncbi/sra-tools/pull/664/files
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='/obj/ngs/ngs-java/' \
            --replacement='/ngs/ngs-java/' \
            "${dict2['name']}-source/ngs/ngs-java/CMakeLists.txt"
        cmake_args=(
            "${shared_cmake_args[@]}"
            "-DVDB_BINDIR=${dict['ncbi_vdb_build']}"
            "-DVDB_INCDIR=${dict['ncbi_vdb_source']}/interfaces"
            "-DVDB_LIBDIR=${dict['ncbi_vdb_build']}/lib"
        )
        koopa_dl 'CMake args' "${cmake_args[*]}"
        "${app['cmake']}" -LH \
            -S "${dict2['name']}-source" \
            -B "${dict2['name']}-build" \
            "${cmake_args[@]}"
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='/obj/ngs/ngs-java/' \
            --replacement='/ngs/ngs-java/' \
            "${dict2['name']}-build/ngs/ngs-java/CMakeFiles/\
ngs-doc-jar.dir/build.make"
        "${app['cmake']}" --build "${dict2['name']}-build"
        "${app['cmake']}" --install "${dict2['name']}-build"
    )
    return 0
}

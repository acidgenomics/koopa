#!/usr/bin/env bash

# FIXME Seeing build error with 3.0.1.
# [ 37%] Built target ngs-doc_javadoc
# /bin/sh: line 0: cd: /private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20221115-172023-4egoHaUTpl/sra-tools-build/obj/ngs/ngs-java/javadoc/ngs-doc: No such file or directory

# FIXME Build is currently failing on Ubuntu 22 ARM.
# [  0%] Built target ktst
# [  0%] Building C object libs/align/CMakeFiles/ncbi-bam.dir/bam.c.o
# In file included from /tmp/koopa-1000-20221201-161856-B0pQYf185z/ncbi-vdb-source/interfaces/kfs/file-v2.h:35,
#                  from /tmp/koopa-1000-20221201-161856-B0pQYf185z/ncbi-vdb-source/interfaces/kfs/file.h:39,
#                  from /tmp/koopa-1000-20221201-161856-B0pQYf185z/ncbi-vdb-source/libs/align/bam.c:32:
# /tmp/koopa-1000-20221201-161856-B0pQYf185z/ncbi-vdb-source/interfaces/kfc/refcount.h:39:10: fatal error: atomic32.h: No such file or directory
#    39 | #include <atomic32.h>
#       |          ^~~~~~~~~~~~
# compilation terminated.
# gmake[2]: *** [libs/align/CMakeFiles/ncbi-bam.dir/build.make:76: libs/align/CMakeFiles/ncbi-bam.dir/bam.c.o] Error 1
# gmake[1]: *** [CMakeFiles/Makefile2:1541: libs/align/CMakeFiles/ncbi-bam.dir/all] Error 2
# gmake: *** [Makefile:146: all] Error 2

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2022-12-01.
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
        'hdf5'
        'libxml2'
        'python'
    )
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
        ['python']="$(koopa_locate_python)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    app['python']="$(koopa_realpath "${app['python']}")"
    declare -A dict=(
        ['base_url']='https://github.com/ncbi'
        ['hdf5']="$(koopa_app_prefix 'hdf5')"
        ['libxml2']="$(koopa_app_prefix 'libxml2')"
        ['openjdk']="$(koopa_app_prefix 'openjdk')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir \
        "${dict['hdf5']}" \
        "${dict['libxml2']}" \
        "${dict['openjdk']}"
    # Ensure we define Java location, otherwise install can hit warnings during
    # ngs-tools install.
    export JAVA_HOME="${dict['openjdk']}"
    # Need to use HDF5 1.10 API.
    export CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    koopa_print_env
    shared_cmake_args=(
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['prefix']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        "-DPython3_EXECUTABLE=${app['python']}"
        "-DHDF5_ROOT=${dict['hdf5']}"
        "-DLIBXML2_INCLUDE_DIR=${dict['libxml2']}/include"
        "-DLIBXML2_LIBRARY=${dict['libxml2']}/lib/libxml2.${dict['shared_ext']}"
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
        # Need to fix '/obj/ngs/ngs-java' path issue in 'CMakeLists.txt' file.
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
        "${app['cmake']}" --build "${dict2['name']}-build"
        "${app['cmake']}" --install "${dict2['name']}-build"
    )
    return 0
}

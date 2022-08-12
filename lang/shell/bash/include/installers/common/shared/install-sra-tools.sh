#!/usr/bin/env bash

# NOTE Consider requiring bison, doxygen, and flex for build environment.
# Can set doxygen with 'DOXYGEN_EXECUTABLE'.

# FIXME Now hitting this error on Ubuntu:
# Adding zlib as a dependency doesn't fix the issue...
#
# > [ 41%] Built target align-info
# > [ 41%] Building C object tools/bam-loader/CMakeFiles/samview.dir/bam.c.o
# > /tmp/koopa-1000-20220812-152017-8xoh32EGWU/sra-tools-3.0.0/tools/bam-loader/bam.c:63:10: fatal error: zlib.h: No such file or directory
# >    63 | #include <zlib.h>
# >       |          ^~~~~~~~
# > compilation terminated.
# > gmake[2]: *** [tools/bam-loader/CMakeFiles/samview.dir/build.make:76: tools/bam-loader/CMakeFiles/samview.dir/bam.c.o] Error 1
# > gmake[1]: *** [CMakeFiles/Makefile2:3090: tools/bam-loader/CMakeFiles/samview.dir/all] Error 2

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2022-08-11.
    #
    # @seealso
    # - https://github.com/ncbi/sra-tools/wiki/
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/ncbi/ngs-tools
    # - https://hpc.nih.gov/apps/sratoolkit.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/sratoolkit.rb
    # - https://stackoverflow.com/questions/53298492/how-to-link-zlib-with-cmake
    # - https://cmake.org/cmake/help/latest/module/FindZLIB.html
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake'
    koopa_activate_opt_prefix \
        'bzip2' \
        'bison' \
        'hdf5' \
        'libxml2' \
        'python'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[cmake]}" ]] || return 1
    [[ -x "${app[python]}" ]] || return 1
    # CMake configuration will pick up Python Framework on macOS unless we
    # set this manually.
    app[python]="$(koopa_realpath "${app[python]}")"
    declare -A dict=(
        [base_url]='https://github.com/ncbi'
        [bison]="$(koopa_app_prefix 'bison')"
        [bzip2]="$(koopa_app_prefix 'bzip2')"
        [hdf5]="$(koopa_app_prefix 'hdf5')"
        [java_home]="$(koopa_java_prefix)"
        [libxml2]="$(koopa_app_prefix 'libxml2')"
        [prefix]="${INSTALL_PREFIX:?}"
        [shared_ext]="$(koopa_shared_ext)"
        [version]="${INSTALL_VERSION:?}"
    )
    # Ensure we define Java location, otherwise can hit warnings during
    # ngs-tools install.
    koopa_assert_is_dir "${dict[java_home]}"
    export JAVA_HOME="${dict[java_home]}"
    # Need to use HDF5 1.10 API.
    export CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    # Build NCBI VDB Software Development Kit (no install).
    (
        local dict2
        declare -A dict2
        dict2[name]='ncbi-vdb'
        dict2[file]="${dict2[name]}-${dict[version]}.tar.gz"
        dict2[url]="${dict[base_url]}/${dict2[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
        koopa_download "${dict2[url]}" "${dict2[file]}"
        koopa_extract "${dict2[file]}"
        "${app[cmake]}" \
            -S "${dict2[name]}-${dict[version]}" \
            -B "${dict2[name]}-${dict[version]}-build" \
            -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
            -DPython3_EXECUTABLE="${app[python]}" \
            -DBISON_EXECUTABLE="${dict[bison]}/bin/bison" \
            -DLIBXML2_INCLUDE_DIR="${dict[libxml2]}/include" \
            -DLIBXML2_LIBRARY="${dict[libxml2]}/lib/libxml2.${dict[shared_ext]}"
        "${app[cmake]}" --build "${dict2[name]}-${dict[version]}-build"
    )
    dict[ncbi_vdb_build]="$( \
        koopa_realpath "ncbi-vdb-${dict[version]}-build" \
    )"
    dict[ncbi_vdb_source]="$( \
        koopa_realpath "ncbi-vdb-${dict[version]}" \
    )"
    # Build and install NCBI SRA Toolkit.
    (
        local dict2
        declare -A dict2
        dict2[name]='sra-tools'
        dict2[file]="${dict2[name]}-${dict[version]}.tar.gz"
        dict2[url]="${dict[base_url]}/${dict2[name]}/archive/refs/tags/\
${dict[version]}.tar.gz"
        koopa_download "${dict2[url]}" "${dict2[file]}"
        koopa_extract "${dict2[file]}"
        # Need to fix '/obj/ngs/ngs-java' path issue in 'CMakeLists.txt' file.
        # See related: https://github.com/ncbi/sra-tools/pull/664/files
        koopa_find_and_replace_in_file \
            --fixed \
            --pattern='/obj/ngs/ngs-java/' \
            --replacement='/ngs/ngs-java/' \
            "${dict2[name]}-${dict[version]}/ngs/ngs-java/CMakeLists.txt"
        "${app[cmake]}" \
            -S "${dict2[name]}-${dict[version]}" \
            -B "${dict2[name]}-${dict[version]}-build" \
            -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
            -DPython3_EXECUTABLE="${app[python]}" \
            -DBZIP2_INCLUDE_DIR="${dict[bzip2]}/include" \
            -DBZIP2_LIBRARIES="${dict[bzip2]}/lib/libbz2.${dict[shared_ext]}" \
            -DHDF5_INCLUDE_DIRS="${dict[hdf5]}/include" \
            -DHDF5_LIBRARIES="${dict[hdf5]}/lib/libhdf5.${dict[shared_ext]}" \
            -DVDB_BINDIR="${dict[ncbi_vdb_build]}" \
            -DVDB_INCDIR="${dict[ncbi_vdb_source]}/interfaces" \
            -DVDB_LIBDIR="${dict[ncbi_vdb_build]}/lib"
        "${app[cmake]}" --build "${dict2[name]}-${dict[version]}-build"
        "${app[cmake]}" --install "${dict2[name]}-${dict[version]}-build"
    )
    return 0
}

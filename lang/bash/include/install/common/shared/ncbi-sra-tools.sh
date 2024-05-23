#!/usr/bin/env bash

# FIXME 3.1.1 is failing to build on Apple Silicon:
# https://github.com/ncbi/sra-tools/issues/937
#
# /bin/sh: -c: line 0: unexpected EOF while looking for matching `"'
# /bin/sh: -c: line 1: syntax error: unexpected end of file
# gmake[2]: *** [tools/external/driver-tool/CMakeFiles/sratools.dir/build.make:79: tools/external/driver-tool/CMakeFiles/sratools.dir/sratools.cpp.o] Error 2
# gmake[2]: Leaving directory '/private/var/folders/9b/4gh0pghx1b71jjd0wjh5mj880000gn/T/tmp.jubUtdSORo/src-cmake-a3d764cd37'
# gmake[1]: *** [CMakeFiles/Makefile2:2920: tools/external/driver-tool/CMakeFiles/sratools.dir/all] Error 2
# gmake[1]: Leaving directory '/private/var/folders/9b/4gh0pghx1b71jjd0wjh5mj880000gn/T/tmp.jubUtdSORo/src-cmake-a3d764cd37'
# gmake: *** [Makefile:169: all] Error 2

main() {
    # """
    # Install SRA toolkit.
    # @note Updated 2024-05-22.
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
    local -a build_deps cmake_args deps
    build_deps+=('bison' 'flex' 'ncbi-vdb' 'python3.12')
    deps+=('icu4c' 'libxml2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['libxml2']="$(koopa_app_prefix 'libxml2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['vdb']="$(koopa_app_prefix 'ncbi-vdb')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
    # If build fails, set '--jobs=1' here for better debugging info.
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

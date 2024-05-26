#!/usr/bin/env bash

main() {
    # """
    # Install NCBI VDB.
    # @note Updated 2024-05-23.
    #
    # VDB is the database engine that all SRA tools use.
    #
    # @seealso
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/ncbi-vdb
    # """
    local -A app dict
    local -a build_deps cmake_args deps
    build_deps=('bison' 'flex')
    deps=('zlib' 'hdf5' 'python3.12')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python312 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['temurin']="$(koopa_app_prefix 'temurin')"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['temurin']}"
    export JAVA_HOME="${dict['temurin']}"
    CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    export CFLAGS
    cmake_args=(
        # > '-DLIBS_ONLY=ON'
        "-DPython3_EXECUTABLE=${app['python']}"
    )
    dict['url']="https://github.com/ncbi/ncbi-vdb/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
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
    koopa_mkdir "${dict['prefix']}"
    koopa_cp --target-directory="${dict['prefix']}/src" 'interfaces'
    (
        koopa_cd "${dict['prefix']}"
        koopa_mkdir 'lib'
        koopa_ln 'lib' 'lib64'
    )
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

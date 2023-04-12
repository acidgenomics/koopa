#!/usr/bin/env bash

main() {
    # """
    # Install NCBI VDB.
    # @note Updated 2023-04-12.
    #
    # VDB is the database engine that all SRA tools use.
    #
    # @seealso
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/ncbi-vdb
    # """
    local -A app dict
    local -a cmake_args deps
    deps=('bison' 'flex' 'hdf5' 'python3.11')
    koopa_activate_app "${deps[@]}"
    app['cmake']="$(koopa_locate_cmake)"
    app['python']="$(koopa_locate_python311 --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['openjdk']="$(koopa_app_prefix 'openjdk')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['openjdk']}"
    export JAVA_HOME="${dict['openjdk']}"
    CFLAGS="-DH5_USE_110_API ${CFLAGS:-}"
    export CFLAGS
    cmake_args=(
        '-DLIBS_ONLY=OFF'
        "-DPython3_EXECUTABLE=${app['python']}"
    )
    dict['url']="https://github.com/ncbi/ncbi-vdb/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Workaround to allow 'clang/aarch64' build to use 'gcc/arm64' directory.
    # Issue ref: https://github.com/ncbi/ncbi-vdb/issues/65
    if koopa_is_macos && koopa_is_aarch64
    then
        (
            koopa_cd 'interfaces/cc/clang'
            koopa_ln '../gcc/arm64' 'arm64'
        )
    fi
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
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

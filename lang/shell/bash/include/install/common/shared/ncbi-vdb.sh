#!/usr/bin/env bash

main() {
    # """
    # Install NCBI VDB.
    # @note Updated 2023-04-03.
    #
    # VDB is the database engine that all SRA tools use.
    #
    # @seealso
    # - https://github.com/ncbi/ncbi-vdb/wiki/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/ncbi-vdb
    # """
    local app deps dict
    declare -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'cmake'
    deps=('bison' 'flex' 'python3.11')
    koopa_activate_app "${deps[@]}"
    app['python']="$(koopa_locate_python311 --realpath)"
    [[ -x "${app['python']}" ]] || return 1
    dict['openjdk']="$(koopa_app_prefix 'openjdk')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['openjdk']}"
    export JAVA_HOME="${dict['openjdk']}"
    cmake_args=("-DPython3_EXECUTABLE=${app['python']}")
    dict['url']="https://github.com/ncbi/ncbi-vdb/archive/refs/tags/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

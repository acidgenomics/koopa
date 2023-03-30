#!/usr/bin/env bash

main() {
    # """
    # Install libdeflate.
    # @note Updated 2023-03-30.
    #
    # @seealso
    # - https://github.com/ebiggers/libdeflate
    # - https://github.com/conda-forge/libdeflate-feedstock/tree/main/recipe
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['url']="https://github.com/ebiggers/libdeflate/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}

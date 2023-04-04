#!/usr/bin/env bash

main() {
    # """
    # Install ONT dorado basecaller.
    # @note Updated 2023-04-04.
    # """
    local deps dict
    declare -A dict
    koopa_assert_has_no_args "$#"
    deps=('hdf5' 'openssl3' 'zstd')
    koopa_activate_app "${deps[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/nanoporetech/dorado/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
}

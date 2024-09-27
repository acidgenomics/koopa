#!/usr/bin/env bash

main() {
    # """
    # Install simdjson.
    # @note Updated 2024-09-27.
    #
    # @seealso
    # - https://simdjson.org/
    # - https://github.com/simdjson/simdjson/
    # - https://formulae.brew.sh/formula/simdjson/
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/simdjson/simdjson/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}

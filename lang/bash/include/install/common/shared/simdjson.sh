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
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cmake_build --prefix="${dict['prefix']}"
    return 0
}

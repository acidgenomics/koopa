#!/usr/bin/env bash

main() {
    # """
    # Install nlohmann-json.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/nlohmann/json
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/
    #     nlohmann-json.rb
    # """
    local -A dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    cmake_args=(
        '-DJSON_BuildTests=OFF'
        '-DJSON_MultipleHeaders=ON'
    )
    dict['url']="https://github.com/nlohmann/json/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

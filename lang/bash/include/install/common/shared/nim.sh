#!/usr/bin/env bash

main() {
    # """
    # Install Nim.
    # @note Updated 2023-06-01.
    #
    # Build script currently is not optimized for multiple cores.
    #
    # @seealso
    # - https://nim-lang.org/docs/koch.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/nim.rb
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://nim-lang.org/download/nim-${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    ./build.sh
    bin/nim c -d:release koch
    ./koch boot -d:release -d:nimUseLinenoise
    ./koch tools
    koopa_cp --target-directory="${dict['prefix']}" ./*
    koopa_assert_is_installed "${dict['prefix']}/bin/nim"
    return 0
}

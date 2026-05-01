#!/usr/bin/env bash

main() {
    # """
    # Install utf8proc.
    # @note Updated 2023-04-11.
    #
    # @seealso
    # - https://juliastrings.github.io/utf8proc/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/utf8proc.rb
    # """
    local -A app dict
    _koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/JuliaStrings/utf8proc/\
archive/v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    "${app['make']}" install prefix="${dict['prefix']}"
    _koopa_rm "${dict['prefix']}/lib/"*'.a'
    return 0
}

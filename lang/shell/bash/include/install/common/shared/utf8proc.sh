#!/usr/bin/env bash

main() {
    # """
    # Install utf8proc.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://juliastrings.github.io/utf8proc/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/utf8proc.rb
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['name']='utf8proc'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/JuliaStrings/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['make']}" install prefix="${dict['prefix']}"
    return 0
}

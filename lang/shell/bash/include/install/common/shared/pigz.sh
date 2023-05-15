#!/usr/bin/env bash

main() {
    # """
    # Install xxhash.
    # @note Updated 2023-05-15.
    #
    # @seealso
    # - https://zlib.net/pigz/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pigz.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'make'
    koopa_activate_app 'zlib' 'zopfli'
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zopfli']="$(koopa_app_prefix 'zopfli')"
    dict['url']="https://zlib.net/pigz/pigz-${dict['version']}.tar.gz"
    dict['zop']="${dict['zopfli']}/lib/libzopfli.${dict['shared_ext']}"
    koopa_assert_is_file "${dict['zop']}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    "${app['make']}" \
        PREFIX="${dict['prefix']}" \
        VERBOSE=1 \
        ZOP="${dict['zop']}"
    koopa_cp \
        --target-directory="${dict['prefix']}/bin" \
        'pigz' \
        'unpigz'
    koopa_cp \
        --target-directory="${dict['prefix']}/share/man/man1" \
        'pigz.1'
    (
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln 'pigz.1' 'unpigz.1'
    )
    return 0
}

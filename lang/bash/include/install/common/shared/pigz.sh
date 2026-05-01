#!/usr/bin/env bash

main() {
    # """
    # Install pigz.
    # @note Updated 2026-01-05.
    #
    # @seealso
    # - https://zlib.net/pigz/
    # - https://github.com/conda-forge/pigz-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/pigz.rb
    # """
    local -A app dict
    _koopa_activate_app --build-only 'make'
    _koopa_activate_app 'zlib'
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://zlib.net/pigz/pigz-${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    "${app['make']}" \
        --jobs="${dict['jobs']}" \
        CC='/usr/bin/gcc' \
        CFLAGS="${CFLAGS:-}" \
        CPPFLAGS="${CPPFLAGS:-}" \
        LDFLAGS="${LDFLAGS:-}" \
        PREFIX="${dict['prefix']}" \
        VERBOSE=1
    _koopa_cp \
        --target-directory="${dict['prefix']}/bin" \
        'pigz' \
        'unpigz'
    _koopa_cp \
        --target-directory="${dict['prefix']}/share/man/man1" \
        'pigz.1'
    (
        _koopa_cd "${dict['prefix']}/share/man/man1"
        _koopa_ln 'pigz.1' 'unpigz.1'
    )
    return 0
}

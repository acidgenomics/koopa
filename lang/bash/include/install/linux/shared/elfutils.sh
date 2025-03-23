#!/usr/bin/env bash

main() {
    # """
    # Install elfutils.
    # @note Updated 2023-06-01.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/elfutils.rb
    # """
    local -A dict
    local -a conf_args deps
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('xz' 'zlib' 'zstd')
    koopa_is_macos && deps+=('gettext')
    deps+=('libiconv')
    koopa_activate_app --build-only 'm4'
    koopa_activate_app "${deps[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir \
        "${dict['gettext']}" \
        "${dict['libiconv']}"
    conf_args=(
        # > '--enable-install-elfh'
        # > '--with-biarch'
        # > '--with-valgrind'
        "--prefix=${dict['prefix']}"
        '--disable-debuginfod'
        '--disable-debugpred'
        '--disable-dependency-tracking'
        '--disable-libdebuginfod'
        '--disable-silent-rules'
        '--program-prefix=eu-'
        '--with-bzlib'
        "--with-libiconv-prefix=${dict['libiconv']}"
        '--with-lzma'
        '--with-zlib'
        '--with-zstd'
    )
    if koopa_is_macos
    then
        conf_args+=(
            "--with-libintl-prefix=${dict['gettext']}"
        )
    fi
    dict['url']="https://sourceware.org/elfutils/ftp/\
${dict['version']}/elfutils-${dict['version']}.tar.bz2"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_make_build "${conf_args[@]}"
    return 0
}

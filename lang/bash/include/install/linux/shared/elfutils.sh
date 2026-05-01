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
    ! _koopa_is_macos && deps+=('bzip2')
    deps+=('xz' 'zlib' 'zstd')
    _koopa_is_macos && deps+=('gettext')
    deps+=('libiconv')
    _koopa_activate_app --build-only 'm4'
    _koopa_activate_app "${deps[@]}"
    dict['gettext']="$(_koopa_app_prefix 'gettext')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['libiconv']="$(_koopa_app_prefix 'libiconv')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    _koopa_assert_is_dir \
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
    if _koopa_is_macos
    then
        conf_args+=(
            "--with-libintl-prefix=${dict['gettext']}"
        )
    fi
    dict['url']="https://sourceware.org/elfutils/ftp/\
${dict['version']}/elfutils-${dict['version']}.tar.bz2"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}

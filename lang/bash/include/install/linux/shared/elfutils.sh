#!/usr/bin/env bash

main() {
    # """
    # Install elfutils.
    # @note Updated 2023-03-27.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/elfutils.rb
    # """
    local -A app dict
    local -a conf_args deps
    deps=(
        'bzip2'
        'xz'
        'zlib'
        # > 'zstd'
    )
    koopa_is_macos && deps+=('gettext')
    deps+=('libiconv')
    koopa_activate_app --build-only 'm4' 'make'
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    dict['name']='elfutils'
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
        '--with-zlib'
        '--without-lzma'
        '--without-zstd'
    )
    if koopa_is_macos
    then
        conf_args+=(
            "--with-libintl-prefix=${dict['gettext']}"
        )
    fi
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://sourceware.org/elfutils/ftp/\
${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

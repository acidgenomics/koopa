#!/usr/bin/env bash

# FIXME Hitting a cryptic permission issue with make-debug-archive.

main() {
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/elfutils.rb
    # """
    local app conf_args dict
    koopa_activate_build_opt_prefix 'm4'
    koopa_activate_opt_prefix \
        'bzip2' \
        'xz' \
        'zlib' \
        'zstd' \
        'gettext' \
        'libiconv'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['gettext']="$(koopa_app_prefix 'gettext')"
        ['jobs']="$(koopa_cpu_count)"
        ['libiconv']="$(koopa_app_prefix 'libiconv')"
        ['name']='elfutils'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
        "--with-libintl-prefix=${dict['gettext']}"
        '--with-zlib'
        '--with-zstd'
        '--without-lzma'
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://sourceware.org/elfutils/ftp/0.187/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}" VERBOSE=1
    "${app['make']}" install
    return 0
}

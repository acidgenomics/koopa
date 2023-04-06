#!/usr/bin/env bash

main() {
    # """
    # Install PCRE2.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.pcre.org/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/pcre2.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'make' \
        'pkg-config'
    koopa_activate_app \
        'zlib' \
        'bzip2'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='pcre2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.bz2"
    dict['url']="https://github.com/PhilipHazel/${dict['name']}/releases/\
download/${dict['name']}-${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--enable-jit'
        '--enable-pcre2-16'
        '--enable-pcre2-32'
        '--enable-pcre2grep-libbz2'
        '--enable-pcre2grep-libz'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

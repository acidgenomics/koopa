#!/usr/bin/env bash

main() {
    # """
    # Install Ruby.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # """
    local -A app dict
    local -a conf_args deps
    koopa_assert_has_no_args "$#"
    deps=(
        'zlib'
        'openssl3'
        # > 'readline'
        'libyaml'
    )
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    # Ensure '2.7.1p83' becomes '2.7.1' here, for example.
    dict['version']="$(koopa_sanitize_version "${dict['version']}")"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['url']="https://cache.ruby-lang.org/pub/ruby/${dict['maj_min_ver']}/\
ruby-${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-silent-rules'
        '--enable-shared'
        '--without-gmp'
    )
    koopa_is_macos && conf_args+=('--enable-dtrace')
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

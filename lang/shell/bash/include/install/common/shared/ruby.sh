#!/usr/bin/env bash

main() {
    # """
    # Install Ruby.
    # @note Updated 2022-11-14.
    #
    # @seealso
    # - https://www.ruby-lang.org/en/downloads/
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    # NOTE Consider adding 'libyaml' here (recommended by Homebrew).
    deps=(
        'zlib'
        'openssl3'
        # > 'readline'
    )
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='ruby'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    # > koopa_assert_is_dir "${dict['openssl']}" "${dict['readline']}"
    # Ensure '2.7.1p83' becomes '2.7.1' here, for example.
    dict['version']="$(koopa_sanitize_version "${dict['version']}")"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.gz"
    dict['url']="https://cache.ruby-lang.org/pub/${dict['name']}/\
${dict['maj_min_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
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

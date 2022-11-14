#!/usr/bin/env bash

# FIXME We may need additional configuration to handle readline inclusion.
# https://github.com/rbenv/ruby-build/issues/1431

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
        # > ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        # > ['readline']="$(koopa_app_prefix 'readline')"
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
    # NOTE Consider adding 'libyaml' here.
    # > local opt_dirs
    # > opt_dirs=(
    # >     "${dict['openssl']}"
    # >     # > "${dict['readline']}"
    # > )
    # > dict['opt_dirs']="$(printf '%s:' "${opt_dirs[@]}")"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-silent-rules'
        '--enable-shared'
        # > "--with-opt-dir=${dict['opt_dirs']}"
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

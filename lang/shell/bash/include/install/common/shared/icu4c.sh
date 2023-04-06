#!/usr/bin/env bash

main() {
    # """
    # Install ICU4C.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://unicode-org.github.io/icu/userguide/icu4c/build.html
    # - https://github.com/unicode-org/icu/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/icu4c.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='icu4c'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['kebab_version']="$(koopa_kebab_case_simple "${dict['version']}")"
    dict['snake_version']="$(koopa_snake_case_simple "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['snake_version']}-src.tgz"
    dict['url']="https://github.com/unicode-org/icu/releases/download/\
release-${dict['kebab_version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd 'icu/source'
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-samples'
        '--disable-tests'
        '--enable-rpath'
        '--enable-shared'
        '--enable-static'
        '--with-library-bits=64'
    )
    koopa_add_rpath_to_ldflags "${dict['prefix']}/lib"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    # Can check configuration success with:
    # > app['icuinfo']="${dict['prefix']}/bin/icuinfo"
    # > koopa_assert_is_installed "${app['icuinfo']}"
    # > "${app['icuinfo']}"
    return 0
}

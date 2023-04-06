#!/usr/bin/env bash

main() {
    # """
    # Install oniguruma regular expressions library.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/oniguruma.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'autoconf' \
        'automake' \
        'libtool' \
        'm4' \
        'make' \
        'pkg-config'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name1']='oniguruma'
    dict['name2']='onig'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['version2']="$(koopa_major_minor_patch_version "${dict['version']}")"
    dict['file']="${dict['name2']}-${dict['version']}.tar.gz"
    dict['url']="https://github.com/kkos/${dict['name1']}/releases/\
download/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name2']}-${dict['version2']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    "${app['autoreconf']}" -vfi
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

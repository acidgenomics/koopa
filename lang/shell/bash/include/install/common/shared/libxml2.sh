#!/usr/bin/env bash

main() {
    # """
    # Install libxml2.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/libxml2.html
    # """
    local -A app dict
    local -a build_deps conf_args deps
    koopa_assert_has_no_args "$#"
    build_deps=('make' 'pkg-config')
    deps=('zlib' 'icu4c' 'readline')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='libxml2'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://download.gnome.org/sources/${dict['name']}/\
${dict['maj_min_ver']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--with-history'
        '--with-icu'
        '--without-lzma'
        '--without-python'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

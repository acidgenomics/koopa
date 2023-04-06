#!/usr/bin/env bash

main() {
    # """
    # Install libpng.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - http://www.libpng.org/pub/png/libpng.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpng.rb
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    koopa_activate_app 'zlib'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='libpng'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    # Convert '1.6.37' to '16'.
    dict['maj_min_ver']="$(koopa_major_minor_version "${dict['version']}")"
    dict['version2']="$( \
        koopa_gsub \
            --fixed \
            --pattern='.' \
            --replacement='' \
            "${dict['maj_min_ver']}" \
    )"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://downloads.sourceforge.net/project/${dict['name']}/\
${dict['name']}${dict['version2']}/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--enable-shared=yes'
        '--enable-static=yes'
    )
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

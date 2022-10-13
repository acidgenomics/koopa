#!/usr/bin/env bash

main() {
    # """
    # Install libpng.
    # @note Updated 2022-08-16.
    #
    # @seealso
    # - http://www.libpng.org/pub/png/libpng.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libpng.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'zlib'
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libpng'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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

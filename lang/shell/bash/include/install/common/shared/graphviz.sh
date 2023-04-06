#!/usr/bin/env bash

# NOTE Consider adding support for: expat, fontconfig, freetype2, openjdk,
# tcl-tk, zlib, X11.
#
# > options:
# >   fontconfig:    No (missing fontconfig-config)
# >   freetype:      No (missing freetype-config)
# >   glut:          No (missing GL/glut.h)
# >   ann:           No (no ann.pc found)
# >   gts:           No (gts library not available)
# >   swig:          No (swig not available) (  )
# >   qt:            No (qmake not found)

main() {
    # """
    # Install graphviz.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://graphviz.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     graphviz.rb
    # - https://ports.macports.org/port/graphviz/details/
    # """
    local -A app dict
    local -a conf_args
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'make' 'pkg-config'
    app['make']="$(koopa_locate_make)"
    [[ -x "${app['make']}" ]] || exit 1
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']='graphviz'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="https://gitlab.com/api/v4/projects/4207231/packages/generic/\
${dict['name']}-releases/${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-debug'
        '--disable-man-pdfs'
        '--enable-shared'
        '--enable-static'
    )
    koopa_mkdir "${dict['prefix']}/lib"
    koopa_print_env
    koopa_dl 'configure args' "${conf_args[*]}"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

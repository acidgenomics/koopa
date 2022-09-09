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
    # @note Updated 2022-07-28.
    #
    # @seealso
    # - https://graphviz.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     graphviz.rb
    # - https://ports.macports.org/port/graphviz/details/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='graphviz'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
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
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    "${app['make']}" install
    return 0
}

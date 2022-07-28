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
    # Install legacy graphviz v2, matching the version bundled with Rgraphviz.
    # @note Updated 2022-07-28.
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='graphviz'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www2.graphviz.org/Archive/ARCHIVE/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--enable-shared'
        '--enable-static'
    )
    koopa_mkdir "${dict[prefix]}/lib"
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

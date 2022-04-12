#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2022-04-12.
    #
    # Alternative approach for SQLite3 dependency:
    # > -DCMAKE_PREFIX_PATH='/opt/koopa/opt/sqlite'
    #
    # @seealso
    # - https://proj.org/install.html
    # - https://github.com/OSGeo/PROJ/issues/2084
    # - https://github.com/tesseract-ocr/tesseract/issues/786
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    # Consider adding 'libtiff' back in a future update.
    koopa_activate_opt_prefix 'pkg-config' 'python' 'sqlite'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='proj'
        # > [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/PROJ/releases/download/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    koopa_add_to_ldflags_start --rpath-only "${dict[prefix]}/lib"
    cmake_args=(
        ../"${dict[name]}-${dict[version]}" \
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_INSTALL_PREFIX=${dict[prefix]}"
        "-DCMAKE_INSTALL_RPATH=${dict[prefix]}/lib"
        '-DENABLE_TIFF=OFF'
        # Can detect libtiff with:
        # > "-DTIFF_INCLUDE_DIR=${dict[opt_prefix]}/libtiff/include"
        # > "-DTIFF_LIBRARY_RELEASE=${dict[opt_prefix]}/libtiff/lib"
    )
    "${app[cmake]}" "${cmake_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

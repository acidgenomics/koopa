#!/usr/bin/env bash

# FIXME Need to resolve this:
#CMake Error at /opt/koopa/app/cmake/3.23.0/share/cmake-3.23/Modules/FindPackageHandleStandardArgs.cmake:230 (message):
#  Could NOT find TIFF (missing: TIFF_LIBRARY TIFF_INCLUDE_DIR)
#Call Stack (most recent call first):
#  /opt/koopa/app/cmake/3.23.0/share/cmake-3.23/Modules/FindPackageHandleStandardArgs.cmake:594 (_FPHSA_FAILURE_MESSAGE)
#  /opt/koopa/app/cmake/3.23.0/share/cmake-3.23/Modules/FindTIFF.cmake:124 (FIND_PACKAGE_HANDLE_STANDARD_ARGS)
#  CMakeLists.txt:193 (find_package)

main() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2022-04-10.
    #
    # Alternative approach for SQLite3 dependency:
    # > -DCMAKE_PREFIX_PATH='/opt/koopa/opt/sqlite'
    #
    # @seealso
    # - https://proj.org/install.html
    # - https://proj.org/install.html#compilation-and-installation-from-
    #     source-code
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'libtiff' 'pkg-config' 'python' 'sqlite'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='proj'
        [opt_prefix]="$(koopa_opt_prefix)"
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
    "${app[cmake]}" \
        ../"${dict[name]}-${dict[version]}" \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}" \
        -DTIFF_INCLUDE_DIR="${dict[opt_prefix]}/libtiff"
        # FIXME Add this: -DTIFF_LIBRARY_RELEASE
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

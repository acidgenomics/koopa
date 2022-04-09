#!/usr/bin/env bash

# FIXME We may need to add build support for 'libtiff' here.

main() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2022-04-07.
    #
    # Alternative approach for SQLite3 dependency:
    # > -DCMAKE_PREFIX_PATH='/opt/koopa/opt/sqlite'
    #
    # @seealso
    # - https://proj.org/install.html#compilation-and-installation-from-
    #     source-code
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'pkg-config' 'python' 'sqlite'
    declare -A app=(
        [cmake]="$(koopa_locate_cmake)"
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='proj'
        [prefix]="${INSTALL_PREFIX:?}"
        [python_version]="$(koopa_variable 'python')"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[python_min_maj_ver]="$( \
        koopa_major_minor_version "${dict[python_version]}" \
    )"
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/OSGeo/PROJ/releases/download/\
${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_mkdir 'build'
    koopa_cd 'build'
    "${app[cmake]}" \
        ../"${dict[name]}-${dict[version]}" \
        -DCMAKE_INSTALL_PREFIX="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

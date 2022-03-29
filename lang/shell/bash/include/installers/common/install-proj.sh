#!/usr/bin/env bash

install_proj() { # {{{1
    # """
    # Install PROJ.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://proj.org/install.html#compilation-and-installation-from-
    #     source-code
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew 2>/dev/null || true)"
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
    if koopa_is_installed "${app[brew]}"
    then
        koopa_activate_homebrew_opt_prefix \
            'libtiff' \
            'pkg-config' \
            "python@${dict[python_min_maj_ver]}" \
            'sqlite3'
    else
        koopa_activate_opt_prefix \
            'python' \
            'sqlite'
    fi
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

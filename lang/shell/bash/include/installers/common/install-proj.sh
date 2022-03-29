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
        [arch]="$(koopa_arch)"
        [jobs]="$(koopa_cpu_count)"
        [make_prefix]="$(koopa_make_prefix)"
        [name]='proj'
        [os]='linux-gnu'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    if koopa_is_installed "${app[brew]}"
    then
        koopa_activate_homebrew_opt_prefix 'pkg-config' 'libtiff' 'sqlite3'
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

#!/usr/bin/env bash

koopa:::install_pkg_config() { # {{{1
    # """
    # Install pkg-config.
    # @note Updated 2022-01-24.
    #
    # Requires cmp and diff to be installed.
    #
    # @seealso
    # - https://www.freedesktop.org/wiki/Software/pkg-config/
    # - https://pkg-config.freedesktop.org/releases/
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='pkg-config'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://${dict[name]}.freedesktop.org/releases/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
    )
    if koopa::is_macos
    then
        conf_args+=(
            '--with-internal-glib'
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

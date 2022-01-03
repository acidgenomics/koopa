#!/usr/bin/env bash

koopa:::install_libevent() { # {{{1
    # """
    # Install libevent.
    # @note Updated 2021-12-09.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [name]='libevent'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}-stable.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/releases/\
download/release-${dict[version]}-stable/${dict[file]}"
    if koopa::is_macos
    then
        # FIXME Bump this to version 3?
        koopa::activate_homebrew_opt_prefix 'openssl@1.1'
    fi
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[version]}-stable"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}

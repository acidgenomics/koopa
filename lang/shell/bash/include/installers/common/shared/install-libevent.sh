#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install libevent.
    # @note Updated 2022-01-19.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #       Formula/libevent.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='libevent'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}-stable.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/releases/\
download/release-${dict[version]}-stable/${dict[file]}"
    if koopa_is_macos
    then
        koopa_activate_homebrew_opt_prefix 'openssl@1.1'
    fi
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}-stable"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" check
    "${app[make]}" install
    return 0
}

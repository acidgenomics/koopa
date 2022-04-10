#!/usr/bin/env bash

main() { # {{{
    # """
    # Install zlib.
    # @note Updated 2022-04-10.
    #
    # @seealso
    # - https://www.zlib.net/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/zlib.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='zlib'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://www.zlib.net/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" install
    return 0
}

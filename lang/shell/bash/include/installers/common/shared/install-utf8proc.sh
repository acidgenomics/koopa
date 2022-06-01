#!/usr/bin/env bash

main() {
    # """
    # Install utf8proc.
    # @note Updated 2022-06-01.
    #
    # @seealso
    # - https://juliastrings.github.io/utf8proc/
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/utf8proc.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [name]='utf8proc'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/JuliaStrings/${dict[name]}/\
archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    "${app[make]}" install prefix="${dict[prefix]}"
    return 0
}

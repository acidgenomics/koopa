#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install pyenv.
    # @note Updated 2022-04-26.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='pyenv'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/archive/\
refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cp \
        "${dict[name]}-${dict[version]}" \
        "${dict[prefix]}"
    return 0
}

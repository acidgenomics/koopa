#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install shUnit2.
    # @note Updated 2022-01-06.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='shunit2'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/kward/${dict[name]}/archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_cp --target-directory="${dict[prefix]}/bin" "${dict[name]}"
    return 0
}

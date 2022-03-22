#!/usr/bin/env bash

install_rmate() { # {{{1
    # """
    # Install rmate.
    # @note Updated 2022-01-24.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='rmate'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/aurora/${dict[name]}/archive/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    koopa_chmod 'a+x' "${dict[name]}"
    koopa_cp --target-directory="${dict[prefix]}/bin" "${dict[name]}"
    return 0
}

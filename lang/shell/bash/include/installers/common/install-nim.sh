#!/usr/bin/env bash

install_nim() { # {{{1
    # """
    # Install Nim.
    # @note Updated 2021-11-16.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='nim'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://nim-lang.org/download/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    ./build.sh
    bin/nim c koch
    ./koch boot -d:release
    ./koch tools
    koopa_cp "${PWD:?}" "${dict[prefix]}"
    return 0
}

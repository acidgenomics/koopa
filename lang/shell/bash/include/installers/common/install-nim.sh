#!/usr/bin/env bash

# FIXME Can we build using multiple cores?

install_nim() { # {{{1
    # """
    # Install Nim.
    # @note Updated 2022-03-29.
    #
    # @seealso
    # - https://nim-lang.org/docs/koch.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/nim.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
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
    bin/nim c -d:release koch
    ./koch boot -d:release -d:nimUseLinenoise
    ./koch tools
    koopa_cp "${PWD:?}" "${dict[prefix]}"
    app[nim]="${dict[prefix]}/bin/nim"
    koopa_assert_is_installed "${app[nim]}"
    koopa_configure_nim "${app[nim]}"
    return 0
}

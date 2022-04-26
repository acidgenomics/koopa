#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Neovim binary.
    # @note Updated 2022-04-13.
    #
    # @seealso
    # - https://github.com/neovim/neovim/releases
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="nvim-macos.tar.gz"
    dict[url]="https://github.com/neovim/neovim/releases/download/\
v${dict[version]}/nvim-macos.tar.gz"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_mv ./nvim-osx64/* --target-directory="${dict[prefix]}"
    return 0
}

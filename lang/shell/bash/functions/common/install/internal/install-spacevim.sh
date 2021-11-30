#!/usr/bin/env bash

koopa:::install_spacevim() { # {{{1
    # """
    # Install SpaceVim.
    # @note Updated 2021-11-23.
    # @seealso
    # - https://spacevim.org
    # - https://spacevim.org/quick-start-guide/
    # - https://spacevim.org/faq/
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa::locate_make)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/SpaceVim/SpaceVim.git'
        [xdg_data_home]="$(koopa::xdg_data_home)"
    )
    # Symlink the font cache, to avoid unnecessary copy step.
    if koopa::is_macos
    then
        koopa::ln "${HOME:?}/Library/Fonts" "${dict[xdg_data_home]}/fonts"
    fi
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"
    # Bug fix for vimproc error.
    # https://github.com/SpaceVim/SpaceVim/issues/435
    dict[vimproc_prefix]="${dict[prefix]}/bundle/vimproc.vim"
    koopa::alert "Fixing vimproc at '${dict[vimproc_prefix]}'."
    (
        koopa::cd "${dict[vimproc_prefix]}"
        "${app[make]}"
    )
    return 0
}

#!/usr/bin/env bash

koopa:::install_dotfiles() { # {{{1
    # """
    # Install dotfiles.
    # @note Updated 2021-11-23.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/acidgenomics/dotfiles.git'
    )
    koopa::git_clone "${dict[url]}" "${dict[prefix]}"

    # FIXME Split this out to separate configure function -----
    koopa::add_koopa_config_link "${dict[prefix]}" "${dict[name]}"
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    "${app[bash]}" "${dict[script]}"
    # FIXME ---------------------------------------------------

    return 0
}

#!/usr/bin/env bash

koopa::configure_dotfiles() { # {{{1
    # """
    # Configure dotfiles.
    # @note Updated 2022-01-19.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="$(koopa::dotfiles_prefix)"
    koopa::assert_is_dir "${dict[prefix]}"
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    koopa::add_koopa_config_link "${dict[prefix]}" "${dict[name]}"
    koopa::add_to_path_start "$(koopa::dirname "${app[bash]}")"
    "${app[bash]}" "${dict[script]}"
    return 0
}

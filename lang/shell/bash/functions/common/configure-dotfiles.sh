#!/usr/bin/env bash

koopa_configure_dotfiles() {
    # """
    # Configure dotfiles.
    # @note Updated 2022-05-16.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    [[ -x "${app[bash]}" ]] || return 1
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="$(koopa_dotfiles_prefix)"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[script]="${dict[prefix]}/install"
    koopa_assert_is_file "${dict[script]}"
    koopa_add_config_link "${dict[prefix]}" "${dict[name]}"
    koopa_add_to_path_start "$(koopa_dirname "${app[bash]}")"
    "${app[bash]}" "${dict[script]}"
    return 0
}

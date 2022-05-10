#!/usr/bin/env bash

koopa_configure_chezmoi() { # {{{1
    # """
    # Configure chezmoi to use koopa managed dotfiles repo.
    # @note Updated 2022-05-10.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [dotfiles_prefix]="$(koopa_dotfiles_prefix)"
        [xdg_data_home]="$(koopa_xdg_data_home)"
    )
    dict[chezmoi_prefix]="${dict[xdg_data_home]}/chezmoi"
    koopa_assert_is_dir "${dict[dotfiles_prefix]}"
    koopa_ln "${dict[dotfiles_prefix]}" "${dict[chezmoi_prefix]}"
    return 0
}

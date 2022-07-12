#!/usr/bin/env bash

koopa_configure_chezmoi() {
    # """
    # Configure chezmoi to use koopa managed dotfiles repo.
    # @note Updated 2022-07-12.
    #
    # Alternative approach:
    # > chezmoi init \
    # >     --apply \
    # >     --verbose \
    # >     https://github.com/acidgenomics/dotfiles.git
    #
    # For private repo, may need to pass '--ssh' flag.
    #
    # @seealso
    # - https://www.chezmoi.io/user-guide/setup/
    # - https://www.chezmoi.io/user-guide/include-files-from-elsewhere/
    # - https://www.chezmoi.io/reference/configuration-file/variables/
    # - https://blog.lazkani.io/posts/dotfiles-with-chezmoi/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [dotfiles_prefix]="$(koopa_dotfiles_prefix)"
        [xdg_data_home]="$(koopa_xdg_data_home)"
    )
    dict[chezmoi_prefix]="${dict[xdg_data_home]}/chezmoi"
    if [[ -d "${dict[dotfiles_prefix]}" ]]
    then
        koopa_ln "${dict[dotfiles_prefix]}" "${dict[chezmoi_prefix]}"
    fi
    return 0
}

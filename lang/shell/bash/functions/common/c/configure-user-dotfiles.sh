#!/usr/bin/env bash

koopa_configure_user_dotfiles() {
    # """
    # Configure dotfiles for current user.
    # @note Updated 2023-04-06.
    #
    # This also configures chezmoi to use our koopa managed dotfiles repo.
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
    local -A app dict
    koopa_assert_has_args_le "$#" 1
    app['bash']="$(koopa_locate_bash --allow-system)"
    if [[ "${app['bash']}" == '/bin/bash' ]] && koopa_is_macos
    then
        app['bash']='/usr/local/bin/bash'
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['cm_prefix']="$(koopa_xdg_data_home)/chezmoi"
    dict['name']='dotfiles'
    dict['prefix']="${1:-}"
    [[ -z "${dict['prefix']}" ]] && dict['prefix']="$(koopa_dotfiles_prefix)"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['script']="${dict['prefix']}/install"
    koopa_assert_is_file "${dict['script']}"
    koopa_ln "${dict['prefix']}" "${dict['cm_prefix']}"
    koopa_add_config_link "${dict['prefix']}" "${dict['name']}"
    koopa_add_to_path_start "$(koopa_dirname "${app['bash']}")"
    "${app['bash']}" "${dict['script']}"
    return 0
}

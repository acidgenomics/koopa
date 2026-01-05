#!/usr/bin/env bash

main() {
    # """
    # Configure dotfiles for current user.
    # @note Updated 2026-01-05.
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
    koopa_assert_has_no_args "$#"
    koopa_assert_is_not_root
    app['bash']="$(koopa_locate_bash --allow-bootstrap --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['opt_prefix']="$(koopa_opt_prefix)/dotfiles"
    dict['df_prefix']="$(koopa_dotfiles_prefix)"
    dict['df_work_prefix']="$(koopa_dotfiles_work_prefix)"
    dict['df_private_prefix']="$(koopa_dotfiles_private_prefix)"
    koopa_assert_is_dir "${dict['opt_prefix']}"
    koopa_ln "${dict['opt_prefix']}" "${dict['df_prefix']}"
    dict['install_script']="${dict['df_prefix']}/install"
    dict['work_install_script']="${dict['df_work_prefix']}/install"
    dict['private_install_script']="${dict['df_private_prefix']}/install"
    koopa_assert_is_file "${dict['install_script']}"
    koopa_add_to_path_start "$(koopa_dirname "${app['bash']}")"
    "${app['bash']}" "${dict['install_script']}"
    if [[ -f "${dict['work_install_script']}" ]]
    then
        "${app['bash']}" "${dict['work_install_script']}"
    fi
    if [[ -f "${dict['private_install_script']}" ]]
    then
        "${app['bash']}" "${dict['private_install_script']}"
    fi
    return 0
}

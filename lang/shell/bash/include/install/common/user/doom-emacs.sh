#!/usr/bin/env bash

main() {
    # """
    # Install Doom Emacs.
    # @note Updated 2023-04-06.
    #
    # Installer flags:
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/install.el
    #
    # Useful doom commands:
    # - doctor
    # - upgrade
    #
    # All the fonts (skipped with '--no-fonts' flag below):
    # - all-the-icons.ttf
    # - file-icons.ttf
    # - fontawesome.ttf
    # - material-design-icons.ttf
    # - octicons.ttf
    # - weathericons.ttf
    # """
    local -A app dict
    koopa_activate_app --build-only 'chemacs'
    if koopa_is_macos
    then
        app['emacs']="$(koopa_macos_emacs)"
    else
        app['emacs']="$(koopa_locate_emacs)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://github.com/hlissner/doom-emacs.git'
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    app['doom']="${dict['prefix']}/bin/doom"
    koopa_assert_is_installed "${app['doom']}"
    koopa_add_to_path_start "$(koopa_dirname "${app['emacs']}")"
    install_args=(
        # > '--no-config'
        # > '--no-install'
        '--no-env'
        '--no-fonts'
    )
    "${app['doom']}" install "${install_args[@]}"
    "${app['doom']}" sync
    # > "${app['doom']}" doctor
    return 0
}

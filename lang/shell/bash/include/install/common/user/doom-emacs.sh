#!/usr/bin/env bash

main() {
    # """
    # Install Doom Emacs.
    # @note Updated 2022-08-31.
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
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'chemacs'
    declare -A app
    if koopa_is_macos
    then
        app['emacs']="$(koopa_macos_emacs)"
    else
        app['emacs']="$(koopa_locate_emacs)"
    fi
    [[ -x "${app['emacs']}" ]] || return 1
    declare -A dict=(
        ['branch']='master'
        ['prefix']="${INSTALL_PREFIX:?}"
        ['url']='https://github.com/hlissner/doom-emacs.git'
    )
    koopa_add_to_path_start "$(koopa_dirname "${app['emacs']}")"
    koopa_git_clone \
        --branch="${dict['branch']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    app['doom']="${dict['prefix']}/bin/doom"
    koopa_assert_is_installed "${app['doom']}"
    install_args=(
        # > '--no-config'
        # > '--no-install'
        '--no-env'
        '--no-fonts'
    )
    "${app['doom']}" --force install "${install_args[@]}"
    "${app['doom']}" --force sync
    # > "${app['doom']}" --force doctor
    return 0
}

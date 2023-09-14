#!/usr/bin/env bash

main() {
    # """
    # Install Doom Emacs.
    # @note Updated 2023-09-14.
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
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://github.com/hlissner/doom-emacs.git'
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    app['doom']="${dict['prefix']}/bin/doom"
    koopa_assert_is_installed "${app['doom']}"
    if koopa_is_linux
    then
        koopa_activate_app --build-only 'emacs'
    elif koopa_is_macos
    then
        koopa_add_to_path_start "$(koopa_homebrew_prefix)/bin"
    fi
    "${app['doom']}" install \
        --debug \
        --force \
        --no-env \
        --no-fonts \
        --verbose
    "${app['doom']}" sync
    # > "${app['doom']}" doctor
    return 0
}

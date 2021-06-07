#!/usr/bin/env bash

# FIXME Need to rework using 'koopa::install_app' here.
# FIXME Need to dynamically support both spacemacs and doom.
# FIXME '--reinstall' is not supported.
# FIXME Need to support an uninstaller.

koopa::install_doom_emacs() { # {{{1
    koopa::install_app \
        --name='doom-emacs' \
        --name-fancy='Doom Emacs' \
        --version='rolling' \
        --no-shared
    return 0
}

koopa:::install_doom_emacs() { # {{{1
    # """
    # Install Doom Emacs.
    # @note Updated 2021-06-07.
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
    local doom install_args prefix repo
    koopa::assert_has_no_args "$#"
    if koopa::is_macos
    then
        # NEED TO ACTIVATE EMACS CASK HERE...
        koopa::activate_emacs
    fi
    koopa::assert_is_installed 'emacs'
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/hlissner/doom-emacs'
    koopa::git_clone "$repo" "$prefix"
    doom="${prefix}/bin/doom"
    koopa::assert_is_executable "$doom"
    install_args=(
        # > '--no-config'
        # > '--no-install'
        '--no-env'
        '--no-fonts'
    )
    "$doom" install "${install_args[@]}"
    "$doom" sync
    "$doom" doctor
    return 0
}

koopa:::update_doom_emacs() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2020-11-25.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local name_fancy
    name_fancy='Doom Emacs'
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'doom'
    koopa::update_start "$name_fancy"
    doom upgrade --force
    doom sync
    koopa::update_success "$name_fancy"
    return 0
}

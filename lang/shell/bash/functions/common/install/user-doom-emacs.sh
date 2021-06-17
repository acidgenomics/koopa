#!/usr/bin/env bash

koopa::install_doom_emacs() { # {{{1
    koopa::install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        --version='rolling' \
        "$@"
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
    local brew_prefix doom install_args prefix repo
    koopa::assert_has_no_args "$#"
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        koopa::add_to_path_start "${brew_prefix}/bin"
    fi
    koopa::assert_is_installed 'emacs'
    koopa::activate_python_packages
    prefix="${INSTALL_PREFIX:?}"
    repo='https://github.com/hlissner/doom-emacs'
    koopa::git_clone --branch='develop' "$repo" "$prefix"
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

koopa::uninstall_doom_emacs() { # {{{1
    # """
    # Uninstall Doom Emacs.
    # @note Updated 2021-06-08.
    # """
    koopa::uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        "$@"
}

koopa::update_doom_emacs() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2021-06-07.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local doom name_fancy
    name_fancy='Doom Emacs'
    koopa::assert_has_no_args "$#"
    doom="$(koopa::locate_doom)"
    koopa::update_start "$name_fancy"
    "$doom" upgrade --force
    "$doom" sync
    koopa::update_success "$name_fancy"
    return 0
}

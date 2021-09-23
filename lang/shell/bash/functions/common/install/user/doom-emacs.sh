#!/usr/bin/env bash

koopa::install_doom_emacs() { # {{{1
    koopa:::install_app \
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
    # @note Updated 2021-07-28.
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
    "$doom" --yes install "${install_args[@]}"
    "$doom" --yes sync
    "$doom" --yes doctor
    return 0
}

koopa::uninstall_doom_emacs() { # {{{1
    # """
    # Uninstall Doom Emacs.
    # @note Updated 2021-06-08.
    # """
    koopa:::uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --no-shared \
        --prefix="$(koopa::doom_emacs_prefix)" \
        "$@"
}

koopa::update_doom_emacs() { # {{{1
    # """
    # Update Doom Emacs.
    # @note Updated 2021-09-23.
    #
    # @seealso
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/upgrade.el
    # """
    local doom name_fancy emacs
    name_fancy='Doom Emacs'
    koopa::assert_has_no_args "$#"
    doom="$(koopa::locate_doom)"
    # FIXME This approach causes warnings about Ruby config on macOS.
    # FIXME Need to rethink putting emacs into '/usr/local/bin' instead?
    emacs="$(koopa::locate_emacs)"
    koopa::add_to_path_start "$(koopa::dirname "$emacs")"
    koopa::update_start "$name_fancy"
    "$doom" --yes upgrade --force
    "$doom" --yes sync
    koopa::update_success "$name_fancy"
    return 0
}

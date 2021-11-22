#!/usr/bin/env bash

koopa:::install_doom_emacs() { # {{{1
    # """
    # Install Doom Emacs.
    # @note Updated 2021-11-22.
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
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [emacs]="$(koopa::locate_emacs)"
    )
    declare -A dict=(
        [branch]='develop'
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/hlissner/doom-emacs.git'
    )
    koopa::add_to_path_start "$(koopa::dirname "${app[emacs]}")"
    koopa::activate_python_packages
    koopa::git_clone \
        --branch="${dict[branch]}" \
        "${dict[url]}" \
        "${dict[prefix]}"
    app[doom]="${dict[prefix]}/bin/doom"
    koopa::assert_is_executable "${app[doom]}"
    install_args=(
        # > '--no-config'
        # > '--no-install'
        '--no-env'
        '--no-fonts'
    )
    "${app[doom]}" --yes install "${install_args[@]}"
    "${app[doom]}" --yes sync
    "${app[doom]}" --yes doctor
    return 0
}

#!/usr/bin/env bash

koopa::install_doom_emacs() { # {{{1
    # """
    # Install Doom Emacs.
    # @note Updated 2020-11-24.
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
    local doom emacs_prefix flags install_dir name name_fancy repo
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed git tee
    name='doom'
    name_fancy='Doom Emacs'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    if [[ -d "$install_dir" ]]
    then
        koopa::alert_note "${name_fancy} already installed at '${install_dir}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$install_dir"
    (
        repo='https://github.com/hlissner/doom-emacs'
        git clone "$repo" "$install_dir"
        doom="${install_dir}/bin/doom"
        flags=(
            # > '--no-config'
            # > '--no-install'
            '--no-env'
            '--no-fonts'
        )
        "$doom" install "${flags[@]}"
        "$doom" sync
        "$doom" doctor
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    # > koopa::link_emacs "$name"
    koopa::install_success "$name_fancy" "$install_dir"
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
    koopa::assert_is_installed doom
    koopa::update_start "$name_fancy"
    doom upgrade --force
    doom sync
    koopa::update_success "$name_fancy"
    return 0
}

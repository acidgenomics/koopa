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

koopa::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2021-03-31.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local emacs_prefix install_dir name name_fancy
    name='spacemacs'
    name_fancy='Spacemacs'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    if [[ -d "$install_dir" ]]
    then
        koopa::alert_note "${name_fancy} is already installed \
at '${install_dir}'."
        return 0
    fi
    koopa::h1 "Installing ${name_fancy} at '${install_dir}."
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
    (
        repo="https://github.com/syl20bnr/${name}.git"
        git clone "$repo" "$install_dir"
        koopa::cd "$install_dir"
        git checkout -b develop origin/develop
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    # > koopa::link_emacs "$name"
    # > koopa::update_spacemacs
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

koopa:::update_spacemacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2021-04-09.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    name_fancy='Spacemacs'
    koopa::update_start "$name_fancy"
    prefix="$(koopa::emacs_prefix)"
    (
        koopa::cd "$prefix"
        git pull
    )
    # Need to run this twice for updates to complete successfully.
    emacs \
        --batch -l "${prefix}/init.el" \
        --eval='(configuration-layer/update-packages t)'
    emacs \
        --batch -l "${prefix}/init.el" \
        --eval='(configuration-layer/update-packages t)'
    koopa::update_success "$name_fancy"
    return 0
}

koopa::update_emacs() { # {{{1
    # """
    # Update Emacs.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_installed emacs
    then
        koopa::alert_note 'Emacs is not installed.'
        return 0
    fi
    if koopa::is_spacemacs_installed
    then
        koopa:::update_spacemacs
    elif koopa::is_doom_emacs_installed
    then
        koopa:::update_doom_emacs
    else
        koopa::alert_note 'Emacs configuration cannot be updated.'
        return 0
    fi
    return 0
}

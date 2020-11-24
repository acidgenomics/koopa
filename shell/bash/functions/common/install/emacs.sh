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
        koopa::note "${name_fancy} already installed at '${install_dir}'."
        return 0
    fi
    koopa::install_start "$name" "$install_dir"
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
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::link_emacs "$name"
    koopa::install_success "$name"
    return 0
}

koopa::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2020-07-30.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local emacs_prefix install_dir name
    name='spacemacs'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    [[ -d "$install_dir" ]] && return 0
    koopa::h1 "Installing ${name} at '${install_dir}."
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
    (
        repo="https://github.com/syl20bnr/${name}.git"
        git clone "$repo" "$install_dir"
        koopa::cd "$install_dir"
        git checkout -b develop origin/develop
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::link_emacs "$name"
    koopa::update_spacemacs
    koopa::install_success "$name"
    return 0
}

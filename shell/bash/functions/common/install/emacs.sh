#!/usr/bin/env bash

koopa::install_doom_emacs() { # {{{1
    # """
    # Install Doom Emacs.
    # @note Updated 2020-07-30.
    # """
    local doom emacs_prefix install_dir name repo
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed git tee
    name='doom'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    [[ -d "$install_dir" ]] && return 0
    koopa::install_start "$name" "$install_dir"
    (
        repo='https://github.com/hlissner/doom-emacs'
        git clone "$repo" "$install_dir"
        doom="${install_dir}/bin/doom"
        "$doom" quickstart
        "$doom" refresh
        "$doom" doctor
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

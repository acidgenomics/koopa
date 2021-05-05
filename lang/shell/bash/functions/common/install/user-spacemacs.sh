#!/usr/bin/env bash

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
    koopa::install_start "$name_fancy" "$install_dir"
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed emacs
    (
        repo="https://github.com/syl20bnr/${name}.git"
        git clone "$repo" "$install_dir"
        koopa::cd "$install_dir"
        git checkout -b develop origin/develop
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    # > koopa::link_emacs "$name"
    koopa::install_success "$name_fancy" "$install_dir"
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

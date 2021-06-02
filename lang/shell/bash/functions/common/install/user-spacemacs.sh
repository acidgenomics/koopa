#!/usr/bin/env bash

# FIXME Need to support installation of both Doom Emacs and Spacemacs
# at the same time...
# FIXME Also need to support updating of both Doom and Spacemacs...



# FIXME '--reinstall' is not supported.
koopa::install_spacemacs() { # {{{1
    # """
    # Install Spacemacs.
    # @note Updated 2021-06-02.
    #
    # Note that master branch is ancient and way behind current codebase.
    # Switching to more recent code on develop branch.
    # """
    local emacs_prefix git install_dir name name_fancy tee
    koopa::assert_has_no_args "$#"
    koopa::activate_emacs
    koopa::assert_is_installed 'emacs'
    git="$(koopa::locate_git)"
    tee="$(koopa::locate_tee)"
    name='spacemacs'
    name_fancy='Spacemacs'
    emacs_prefix="$(koopa::emacs_prefix)"
    install_dir="${emacs_prefix}-${name}"
    if [[ -d "$install_dir" ]]
    then
        # FIXME Is there a function we already have defined?
        koopa::alert_note "${name_fancy} is already installed \
at '${install_dir}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$install_dir"
    (
        repo="https://github.com/syl20bnr/${name}.git"
        koopa::git_clone "$repo" "$install_dir"
        koopa::cd "$install_dir"
        "$git" checkout -b 'develop' 'origin/develop'
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    # > koopa::link_emacs "$name"
    koopa::install_success "$name_fancy" "$install_dir"
    return 0
}

koopa:::update_spacemacs() { # {{{1
    # """
    # Update spacemacs non-interatively.
    # @note Updated 2021-06-02.
    #
    # Potentially useful: 'emacs --no-window-system'
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    koopa::activate_emacs
    koopa::assert_is_installed 'emacs'
    name_fancy='Spacemacs'
    koopa::update_start "$name_fancy"
    prefix="$(koopa::emacs_prefix)"
    (
        koopa::cd "$prefix"
        koopa::git_pull
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

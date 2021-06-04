#!/usr/bin/env bash

# Temporarily disabled, until we rethink Python and/or Rust approach.
# > koopa::install_py_koopa() { # {{{1
# >     # """
# >     # Install Python koopa package.
# >     # @note Updated 2021-01-20.
# >     # """
# >     local url
# >     koopa::python_add_site_packages_to_sys_path
# >     url='https://github.com/acidgenomics/py-koopa/archive/main.zip'
# >     koopa::pip_install "$url"
# >     return 0
# > }

koopa::install_r_koopa() { # {{{1
    # """
    # Install koopa R package.
    # @note Updated 2020-01-04.
    # """
    koopa::rscript 'header'
    return 0
}

koopa::uninstall_koopa() { # {{{1
    # """
    # Uninstall koopa.
    # @note Updated 2020-06-24.
    # """
    "$(koopa::prefix)/uninstall" "$@"
    return 0
}

koopa::update_koopa() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2021-01-19.
    #
    # Note that stable releases are not git, and can't be updated.
    # """
    local koopa_prefix name_fancy url version
    name_fancy='koopa'
    koopa_prefix="$(koopa::prefix)"
    if ! koopa::is_git_toplevel "$koopa_prefix"
    then
        version="$(koopa::version)"
        url="$(koopa::url)"
        koopa::alert_note \
            "Stable release of ${name_fancy} ${version} detected." \
            "To update, first run the 'uninstall' script." \
            "Then run the default install command at '${url}'."
        return 1
    fi
    koopa::update_start "$name_fancy" "${koopa_prefix}"
    koopa::sys_set_permissions -r "$koopa_prefix"
    koopa::sys_git_pull
    koopa::update_dotfiles \
        "$(koopa::dotfiles_prefix)" \
        "$(koopa::dotfiles_private_prefix)"
    koopa::sys_set_permissions -r "$koopa_prefix"
    koopa::fix_zsh_permissions
    koopa::update_success "$name_fancy" "$koopa_prefix"
    return 0
}

koopa::update_koopa_system() { # {{{1
    # """
    # Update system installation.
    # @note Updated 2021-05-06.
    # """
    local conf_args
    koopa::assert_is_admin
    koopa::update_koopa
    koopa::h1 'Updating system configuration.'
    koopa::dl \
        'Make prefix' "$(koopa::make_prefix)" \
        'Opt prefix' "$(koopa::opt_prefix)" \
        'User config prefix' "$(koopa::config_prefix)"
    koopa::add_make_prefix_link
    if koopa::is_linux
    then
        koopa::update_etc_profile_d
        koopa::update_ldconfig
    fi
    if koopa::is_linux
    then
        conf_args=('--no-check')
        koopa::linux_configure_system "${conf_args[@]}"
    fi
    if koopa::is_installed 'brew'
    then
        koopa::update_homebrew
    else
        koopa::update_google_cloud_sdk
        koopa::update_perlbrew
        koopa::update_pyenv
        koopa::update_rbenv
    fi
    koopa::update_r_packages
    koopa::update_rust
    koopa::update_rust_packages
    if koopa::is_macos
    then
        koopa::macos_update_microsoft_office || true
    fi
    koopa::alert_success 'System update was successful.'
    return 0
}

koopa::update_koopa_user() { # {{{1
    # """
    # Update koopa user configuration.
    # @note Updated 2021-01-19.
    # """
    local config_prefix local_data_prefix
    config_prefix="$(koopa::config_prefix)"
    local_data_prefix="$(koopa::local_data_prefix)"
    koopa::h1 'Updating user configuration.'
    # Remove legacy directories from user config, if necessary.
    koopa::rm \
        "${config_prefix}/Rcheck" \
        "${config_prefix}/home" \
        "${config_prefix}/oh-my-zsh" \
        "${config_prefix}/pyenv" \
        "${config_prefix}/rbenv" \
        "${config_prefix}/spacemacs"
    # Update git repos.
    repos=(
        "${config_prefix}/docker"
        "${config_prefix}/docker-private"
        "${config_prefix}/dotfiles-private"
        "${config_prefix}/scripts-private"
        "${local_data_prefix}/Rcheck"
    )
    for repo in "${repos[@]}"
    do
        [[ -d "$repo" ]] || continue
        (
            koopa::cd "$repo"
            koopa::git_pull
        )
    done
    ! koopa::is_shared_install && \
        koopa::update_dotfiles "$(koopa::dotfiles_prefix)"
    koopa::update_dotfiles "$(koopa::dotfiles_private_prefix)"
    # > koopa::update_emacs
    koopa::alert_success 'User configuration update was successful.'
    return 0
}

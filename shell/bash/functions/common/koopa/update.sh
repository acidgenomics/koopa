#!/usr/bin/env bash

koopa::update() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2020-11-18.
    # """
    local f fun name
    name="${1:-}"
    case "$name" in
        '')
            name='koopa'
            ;;
        system|user)
            name="koopa_${name}"
            ;;
        # Defunct ----------------------------------------------------------
        --fast)
            koopa::defunct 'koopa update'
            ;;
        --source-ip=*)
            koopa::defunct 'koopa configure-vm --source-ip=SOURCE_IP'
            ;;
        --system)
            koopa::defunct 'koopa update system'
            ;;
        --user)
            koopa::defunct 'koopa update user'
            ;;
    esac
    f="update_${name//-/_}"
    # FIXME MAKE THIS A FUNCTION.
    if koopa::is_macos && koopa::is_function "koopa::macos_${f}"
    then
        fun="koopa::macos_${f}"
    elif koopa::is_linux && koopa::is_function "koopa::linux_${f}"
    then
        fun="koopa::linux_${f}"
    else
        fun="koopa::${f}"
    fi
    if ! koopa::is_function "$fun"
    then
        koopa::stop "No update script available for '${*}'."
    fi
    shift 1
    "$fun" "$@"
    return 0
}

koopa::update_koopa() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2020-11-17.
    #
    # Note that stable releases are not git, and can't be updated.
    # """
    local dotfiles_prefix koopa_prefix
    koopa_prefix="$(koopa::prefix)"
    if ! koopa::is_git_toplevel "$koopa_prefix"
    then
        version="$(koopa::version)"
        url="$(koopa::url)"
        koopa::note \
            "Stable release of koopa ${version} detected." \
            "To update, first run the 'uninstall' script." \
            "Then run the default install command at '${url}'."
        return 1
    fi
    koopa::h1 "Updating koopa at '${koopa_prefix}'."
    koopa::sys_set_permissions -r "$koopa_prefix"
    koopa::sys_git_pull
    (
        dotfiles_prefix="$(koopa::dotfiles_prefix)"
        koopa::cd "$dotfiles_prefix"
        koopa::git_set_remote_url \
            'https://github.com/acidgenomics/dotfiles.git'
        koopa::git_reset
        koopa::git_pull
    )
    koopa::sys_set_permissions -r "$koopa_prefix"
    return 0
}

# FIXME REWORK.
koopa::update_koopa_system() { # {{{1
    # """
    # Update system installation.
    # @note Updated 2020-11-17.
    # """
    local app_prefix config_prefix make_prefix
    koopa::update_koopa
    koopa::h2 'Updating system configuration.'
    koopa::assert_has_sudo
    app_prefix="$(koopa::app_prefix)"
    config_prefix="$(koopa::config_prefix)"
    make_prefix="$(koopa::make_prefix)"
    koopa::dl \
        'App prefix' "${app_prefix}" \
        'Config prefix' "${config_prefix}" \
        'Make prefix' "${make_prefix}"
    koopa::add_make_prefix_link
    if koopa::is_linux
    then
        koopa::update_etc_profile_d
        koopa::update_ldconfig
    fi
    if koopa::is_linux
    then
        # Allow passthrough of specific arguments to 'configure-vm' script.
        configure_flags=('--no-check')
        koopa::configure_vm "${configure_flags[@]}"
    fi
    koopa::update_homebrew
    install-r-packages
    update-r-packages
    koopa::install_python_packages
    koopa::update_rust
    koopa::install_rust_packages
    koopa::update_perlbrew
    # FIXME REWORK.
    koopa::update_google_cloud_sdk
    # FIXME REWORK.
    koopa::update_pyenv
    # FIXME REWORK.
    koopa::update_rbenv
    if koopa::is_macos
    then
        koopa::macos_update_microsoft_office || true
    fi
    koopa::fix_zsh_permissions
    return 0
}

# FIXME REWORK.
koopa::update_koopa_user() { # {{{1
    # """
    # Update koopa user configuration.
    # @note Updated 2020-11-16.
    # """
    koopa::h2 'Updating user configuration.'
    # Remove legacy directories from user config, if necessary.
    koopa::rm "${config_prefix}/"\
{'Rcheck','oh-my-zsh','pyenv','rbenv','spacemacs'}
    # Update git repos.
    repos=(
        "${config_prefix}/docker"
        "${config_prefix}/docker-private"
        "${config_prefix}/dotfiles-private"
        "${config_prefix}/scripts-private"
        "${XDG_DATA_HOME}/Rcheck"
        "${HOME}/.emacs.d-doom"
    )
    for repo in "${repos[@]}"
    do
        [[ -d "$repo" ]] || continue
        (
            koopa::cd "$repo"
            koopa::git_pull
        )
    done
    koopa::install_dotfiles
    koopa::install_dotfiles_private
    koopa::update_spacemacs
    return 0
}

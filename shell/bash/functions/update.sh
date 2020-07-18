#!/usr/bin/env bash

koopa::update() { # {{{1
    # """
    # Update koopa installation.
    # @note Updated 2020-07-18.
    # """
    local app_prefix config_prefix configure_flags core dotfiles \
        dotfiles_prefix fast koopa_prefix make_prefix repos repo source_ip \
        system user
    koopa_prefix="$(koopa::prefix)"
    # Note that stable releases are not git, and can't be updated.
    if ! koopa::is_git_toplevel "$koopa_prefix"
    then
        version="$(koopa::version)"
        url="$(koopa::url)"
        koopa::note \
            "Stable release of koopa ${version} detected." \
            'To update, first run the "uninstall" script.' \
            "Then run the default install command at \"${url}\"."
        return 1
    fi
    config_prefix="$(koopa::config_prefix)"
    app_prefix="$(koopa::app_prefix)"
    make_prefix="$(koopa::make_prefix)"
    core=1
    dotfiles=1
    fast=0
    source_ip=
    system=0
    user=0
    while (("$#"))
    do
        case "$1" in
            --fast)
                fast=1
                shift 1
                ;;
            --source-ip=*)
                source_ip="${1#*=}"
                shift 1
                ;;
            --source-ip)
                source_ip="$2"
                shift 2
                ;;
            --system)
                system=1
                shift 1
                ;;
            --user)
                user=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "$source_ip" ]]
    then
        rsync=1
        system=1
    else
        rsync=0
    fi
    if [[ "$fast" -eq 1 ]]
    then
        dotfiles=0
    fi
    if [[ "$user" -eq 1 ]] && [[ "$system" -eq 0 ]]
    then
        core=0
        dotfiles=0
    fi
    if [[ "$system" -eq 1 ]]
    then
        user=1
    fi
    koopa::h1 "Updating koopa at \"${koopa_prefix}\"."
    koopa::sys_set_permissions -r "$koopa_prefix"
    if [[ "$rsync" -eq 0 ]]
    then
        # Update koopa.
        if [[ "$core" -eq 1 ]]
        then
            koopa::sys_git_pull
        fi
        # Ensure dotfiles are current.
        if [[ "$dotfiles" -eq 1 ]]
        then
            (
                dotfiles_prefix="$(koopa::dotfiles_prefix)"
                cd "$dotfiles_prefix" || exit 1
                # Preivously, this repo was at 'mjsteinbaugh/dotfiles'.
                koopa::git_set_remote_url \
                    'https://github.com/acidgenomics/dotfiles.git'
                koopa::git_reset
                koopa::git_pull origin master
            )
        fi
        koopa::sys_set_permissions -r "$koopa_prefix"
    fi
    koopa::update_xdg_config
    if [[ "$system" -eq 1 ]]
    then
        koopa::h2 'Updating system configuration.'
        koopa::assert_has_sudo
        koopa::dl 'App prefix' "${app_prefix}"
        koopa::dl 'Config prefix' "${config_prefix}"
        koopa::dl 'Make prefix' "${make_prefix}"
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
            if [[ "$rsync" -eq 1 ]]
            then
                configure_flags+=("--source-ip=${source_ip}")
            fi
            koopa::configure_vm "${configure_flags[@]}"
        fi
        if [[ "$rsync" -eq 0 ]]
        then
            koopa::update_perlbrew
            koopa::update_python_packages
            koopa::update_rust
            koopa::update_rust_packages
            update-r-packages
            if koopa::is_linux
            then
                koopa::update_google_cloud_sdk
                koopa::update_pyenv
                koopa::update_rbenv
            elif koopa::is_macos
            then
                koopa::macos_update_homebrew
                koopa::macos_update_microsoft_office
            fi
        fi
        koopa::fix_zsh_permissions
    fi
    if [[ "$user" -eq 1 ]]
    then
        koopa::h2 'Updating user configuration.'
        # Remove legacy directories from user config, if necessary.
        koopa::rm "${config_prefix}/"\
{'Rcheck','autojump','oh-my-zsh','pyenv','rbenv','spacemacs'}
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
    fi
    koopa::success 'koopa update was successful.'
    koopa::restart
    [[ "$system" -eq 1 ]] && koopa::koopa check-system
    return 0
}


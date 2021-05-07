#!/usr/bin/env bash

koopa::install_homebrew() { # {{{1
    # """
    # Install Homebrew.
    # @note Updated 2021-04-22.
    #
    # @seealso
    # - https://docs.brew.sh/Installation
    # - https://github.com/Homebrew/legacy-homebrew/issues/
    #       46779#issuecomment-162819088
    # - https://github.com/Linuxbrew/brew/issues/556
    #
    # macOS:
    # NOTE This function won't run on macOS clean install due to very old Bash.
    # Installs to '/usr/local' on Intel and '/opt/homebrew' on Apple Silicon.
    #
    # Linux:
    # Creates a new linuxbrew user and installs to /home/linuxbrew/.linuxbrew.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_installed brew
    then
        koopa::alert_note 'Homebrew is already installed.'
        return 0
    fi
    koopa::assert_has_sudo
    koopa::assert_is_installed yes
    name_fancy='Homebrew'
    koopa::install_start "$name_fancy"
    koopa::is_macos && koopa::macos_install_xcode_clt
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        chmod +x "$file"
        yes | "./${file}" || true
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_homebrew_bundle() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2021-05-06.
    #
    # Custom brewfile is supported using a positional argument.
    # """
    local brewfile install_args name_fancy
    koopa::assert_has_no_args_le "$#" 1
    koopa::assert_has_sudo
    brewfile="${1:-$(koopa::brew_brewfile)}"
    name_fancy='Homebrew Bundle'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed brew
    koopa::assert_is_file "$brewfile"
    koopa::dl 'Brewfile' "$brewfile"
    brew analytics off
    install_args=(
        # > '--debug'
        # > '--verbose'
        "--file=${brewfile}"
        '--force'
        '--no-lock'
        '--no-upgrade'
    )
    # Note that cask specific args are handled by 'HOMEBREW_CASK_OPTS' global
    # variable, which is defined in our main Homebrew activation function.
    brew bundle install "${install_args[@]}"
    return 0
}

koopa::install_homebrew_packages() { # {{{1
    # """
    # Install Homebrew packages via bundle (user-friendly alias).
    # @note Updated 2021-04-22.
    # """
    koopa::install_homebrew_bundle "$@"
    return 0
}

koopa::uninstall_homebrew() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2021-05-07.
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local file name_fancy tmp_dir url user
    if ! koopa::is_installed brew
    then
        koopa::alert_not_installed 'Homebrew'
        return 0
    fi
    koopa::assert_has_sudo
    koopa::assert_is_installed yes
    name_fancy='Homebrew'
    user="$(koopa::user)"
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    # Note that macOS Catalina now uses Zsh instead of Bash by default.
    if koopa::is_macos
    then
        koopa::alert 'Changing default shell to system Zsh.'
        chsh -s '/bin/zsh' "$user"
    fi
    # > koopa::alert "Resetting permissions in '/usr/local'."
    # > sudo chown -Rhv "$user" '/usr/local/'*
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='uninstall.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        chmod +x "$file"
        yes | "./${file}" || true
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::uninstall_success "$name_fancy"
    return 0
}

koopa::update_homebrew() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2021-04-27.
    #
    # @seealso
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    koopa::assert_has_sudo
    name_fancy='Homebrew'
    koopa::update_start "$name_fancy"
    # > koopa::brew_reset_permissions
    koopa::brew_reset_core_repo
    brew analytics off
    brew update &>/dev/null
    koopa::is_macos && koopa::macos_brew_upgrade_casks
    koopa::brew_upgrade_brews
    koopa::brew_cleanup
    # > koopa::brew_reset_permissions
    koopa::update_success "$name_fancy"
    return 0
}

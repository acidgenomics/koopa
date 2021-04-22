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
    if koopa::is_macos
    then
        koopa::assert_is_installed xcode-select
        koopa::alert 'Installing Xcode command line tools (CLT).'
        xcode-select --install &>/dev/null || true
    fi
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
    # @note Updated 2021-04-22.
    # """
    local brewfile cask_flags flags name_fancy
    koopa::assert_has_no_args_le "$#" 1
    koopa::assert_has_sudo
    brewfile="${1:-$(koopa::brewfile)}"
    name_fancy='Homebrew Bundle'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed brew
    koopa::assert_is_file "$brewfile"
    koopa::dl 'Brewfile' "$brewfile"
    brew analytics off
    flags=(
        # > '--debug'
        # > '--verbose'
        "--file=${brewfile}"
        '--force'
        '--no-lock'
        '--no-upgrade'
    )
    cask_flags=('--no-binaries' '--no-quarantine')
    export HOMEBREW_CASK_OPTS="${cask_flags[*]}"
    brew bundle install "${flags[@]}"
    return 0
}

koopa::install_homebrew_packages() { # {{{1
    koopa::install_homebrew_bundle "$@"
    return 0
}

koopa::uninstall_homebrew() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2021-03-18.
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local file name_fancy tmp_dir url user
    if ! koopa::is_installed brew
    then
        koopa::alert_note 'Homebrew is not installed.'
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
    # @note Updated 2021-04-22.
    #
    # Alternative approaches:
    # > brew list \
    # >     | xargs brew reinstall --cleanup \
    # >     || true
    # > brew outdated --cask --greedy \
    # >     | xargs brew reinstall \
    # >     || true
    #
    # @seealso
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # - https://github.com/Homebrew/brew/issues/9139
    # """
    local cask_flags casks name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    koopa::assert_has_sudo
    name_fancy='Homebrew'
    koopa::update_start "$name_fancy"
    if koopa::is_macos
    then
        cask_flags=(
            # > '--debug'
            # > '--verbose'
            '--force'
            '--no-binaries'
            '--no-quarantine'
        )
        export HOMEBREW_CASK_OPTS="${cask_flags[*]}"
    fi
    # > if koopa::has_sudo
    # > then
    # >     local group prefix user
    # >     user="$(koopa::user)"
    # >     group="$(koopa::admin_group)"
    # >     prefix="$(koopa::homebrew_prefix)"
    # >     koopa::alert "Resetting '${prefix}' to '${user}:${group}'."
    # >     sudo chown -Rh "${user}:${group}" "${prefix}/"*
    # > fi
    koopa::alert "Ensuring internal 'homebrew-core' repo is clean."
    # See also:
    # - https://thecoatlessprofessor.com/programming/
    #       macos/updating-a-homebrew-formula/
    (
        koopa::cd "$(brew --repo 'homebrew/core')"
        # FIXME USE A DEFAULT BRANCH RATHER THAN MASTER HARD CODE HERE.
        git checkout -q 'master'
        git branch -q 'master' -u 'origin/master'
        git reset -q --hard 'origin/master'
        # > git branch -vv
    )
    koopa::alert 'Updating brews.'
    brew analytics off
    brew update
    brew upgrade || true
    if koopa::is_macos
    then
        koopa::alert 'Updating casks.'
        readarray -t casks <<< "$(koopa::macos_brew_cask_outdated)"
        if koopa::is_array_non_empty "${casks[@]}"
        then
            koopa::alert_info "${#casks[@]} outdated casks detected."
            koopa::print "${casks[@]}"
            for cask in "${casks[@]}"
            do
                cask="$(koopa::print "${cask[@]}" | cut -d ' ' -f 1)"
                case "$cask" in
                    docker)
                        cask='homebrew/cask/docker'
                        ;;
                    macvim)
                        cask='homebrew/cask/macvim'
                        ;;
                esac
                brew reinstall --cask --force "${cask_flags[@]}" "$cask" || true
                [[ "$cask" == 'r' ]] && koopa::update_r_config
            done
        fi
    fi
    koopa::alert 'Running cleanup.'
    brew cleanup -s || true
    koopa::rm "$(brew --cache)"
    # > if koopa::has_sudo
    # > then
    # >     koopa::alert "Resetting '${prefix}' to '${user}:${group}'."
    # >     sudo chown -Rh "${user}:${group}" "${prefix}/"*
    # > fi
    koopa::update_success "$name_fancy"
    return 0
}

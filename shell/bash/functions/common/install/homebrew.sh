#!/usr/bin/env bash

koopa::install_homebrew() { # {{{1
    # """
    # Install Homebrew.
    # @note Updated 2020-11-18.
    #
    # @seealso
    # - https://docs.brew.sh/Installation
    # - https://github.com/Homebrew/legacy-homebrew/issues/
    #       46779#issuecomment-162819088
    # - https://github.com/Linuxbrew/brew/issues/556
    #
    # macOS:
    # This script installs Homebrew to '/usr/local' so that you don't need sudo
    # when you run 'brew install'. It is a careful script; it can be run even if
    # you have stuff installed to '/usr/local' already. It tells you exactly
    # what it will do before it does it too. You have to confirm everything it
    # will do before it starts.
    #
    # Linux:
    # Creates a new linuxbrew user and installs to /home/linuxbrew/.linuxbrew.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_installed brew
    then
        koopa::note 'Homebrew is already installed.'
        return 0
    fi
    koopa::assert_has_sudo
    koopa::assert_is_installed yes
    name_fancy='Homebrew'
    koopa::install_start "$name_fancy"
    if koopa::is_macos
    then
        koopa::assert_is_installed xcode-select
        koopa::h2 'Installing Xcode command line tools (CLT).'
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

koopa::install_homebrew_packages() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2020-11-20.
    # """
    local brewfile flags name_fancy remove_brews remove_taps x
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    name_fancy='Homebrew Bundle'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed brew
    export HOMEBREW_FORCE_BOTTLE=1
    brewfile="$(koopa::brewfile)"
    koopa::assert_is_file "$brewfile"
    koopa::dl 'Brewfile' "$brewfile"
    # Remove any existing unwanted brews, if necessary.
    remove_brews=(
        'osgeo-gdal'
        'osgeo-hdf4'
        'osgeo-libgeotiff'
        'osgeo-libkml'
        'osgeo-libspatialite'
        'osgeo-netcdf'
        'osgeo-postgresql'
        'osgeo-proj'
    )
    if koopa::is_macos
    then
        remove_brews+=(
            'little-snitch'
            'safari-technology-preview'
        )
    fi
    for x in "${remove_brews[@]}"
    do
        brew remove "$x" &>/dev/null || true
    done
    remove_taps=(
        'muesli/tap'
    )
    for x in "${remove_taps[@]}"
    do
        brew untap "$x" &>/dev/null || true
    done
    flags=(
        # > --no-upgrade
        "--file=${brewfile}"
        '--no-lock'
        '--verbose'
    )
    brew bundle install "${flags[@]}"
    return 0
}

koopa::uninstall_homebrew() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2020-11-18.
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local file name_fancy tmp_dir url
    if ! koopa::is_installed brew
    then
        koopa::note 'Homebrew is not installed.'
        return 0
    fi
    koopa::assert_has_sudo
    koopa::assert_is_installed yes
    name_fancy='Homebrew'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    # Note that macOS Catalina now uses Zsh instead of Bash by default.
    if koopa::is_macos
    then
        koopa::h2 'Changing default shell to system Zsh.'
        chsh -s '/bin/zsh' "$USER"
    fi
    koopa::h2 "Resetting permissions in '/usr/local'."
    sudo chown -Rhv "$USER" '/usr/local/'*
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
    # @note Updated 2020-11-20.
    #
    # Use of '--force-bottle' flag can be helpful, but not all brews have
    # bottles, so this can error.
    #
    # Alternative approaches:
    # > brew list \
    # >     | xargs brew reinstall --force-bottle --cleanup \
    # >     || true
    # > brew outdated --cask --greedy \
    # >     | xargs brew reinstall \
    # >     || true
    #
    # @seealso
    # - Refer to useful discussion regarding '--greedy' flag.
    # - https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # """
    local casks name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    koopa::assert_has_sudo
    name_fancy='Homebrew'
    koopa::update_start "$name_fancy"
    brew analytics off
    brew update >/dev/null
    koopa::install_homebrew_packages
    koopa::h2 'Updating brews.'
    brew upgrade || true
    if koopa::is_macos
    then
        koopa::h2 'Updating casks.'
        readarray -t casks <<< "$(koopa::macos_brew_cask_outdated)"
        if koopa::is_array_non_empty "${casks[@]}"
        then
            koopa::info "${#casks[@]} outdated casks detected."
            koopa::print "${casks[@]}"
            for cask in "${casks[@]}"
            do
                cask="$(koopa::print "${cask[@]}" | cut -d ' ' -f 1)"
                case "$cask" in
                    docker)
                        cask='homebrew/cask/docker'
                        ;;
                esac
                brew reinstall "$cask" || true
                if [[ "$cask" == 'r' ]]
                then
                    koopa::update_r_config
                fi
            done
        fi
    fi
    koopa::h2 'Running cleanup.'
    brew cleanup -s || true
    koopa::rm "$(brew --cache)"
    koopa::update_success "$name_fancy"
    return 0
}

#!/usr/bin/env bash

koopa::brew_cask_outdated() { # {{{
    # """
    # List outdated Homebrew casks.
    # @note Updated 2020-07-03.
    #
    # Need help with capturing output:
    # - https://stackoverflow.com/questions/58344963/
    # - https://unix.stackexchange.com/questions/253101/
    #
    # @seealso
    # - brew leaves
    # - brew deps --installed --tree
    # - brew list --versions
    # - brew info
    # """
    local tmp_file x
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    tmp_file="$(koopa::tmp_file)"
    script -q "$tmp_file" brew cask outdated --greedy >/dev/null
    x="$(grep -v '(latest)' "$tmp_file")"
    [[ -n "$x" ]] && return 0
    koopa::print "$x"
    return 0
}

koopa::brew_cask_quarantine_fix() { # {{{1
    sudo xattr -r -d com.apple.quarantine /Applications/*.app
    return 0
}

koopa::brewfile() { # {{{1
    # """
    # Homebrew Bundle Brewfile path.
    # @note Updated 2020-07-17.
    # """
    local file
    file="$(koopa::dotfiles_prefix)/os/macos/app/homebrew/Brewfile"
    [[ -f "$file" ]] || return 1
    koopa::print "$file"
    return 0
}

koopa::brew_outdated() { # {{{
    # """
    # Listed outdated Homebrew brews and casks, in a single call.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::h1 'Checking for outdated Homebrew formula.'
    brew update &>/dev/null
    koopa::h2 'Brews'
    brew outdated
    koopa::h2 'Casks'
    koopa::brew_cask_outdated
    return 0
}

koopa::brew_update() { # {{{1
    # """
    # Updated outdated Homebrew brews and casks.
    # @note Updated 2020-07-01.
    #
    # Alternative approaches:
    # > brew list \
    # >     | xargs brew reinstall --force-bottle --cleanup \
    # >     || true
    # > brew cask outdated --greedy \
    # >     | xargs brew cask reinstall \
    # >     || true
    #
    # @seealso
    # Refer to useful discussion regarding '--greedy' flag.
    # https://discourse.brew.sh/t/brew-cask-outdated-greedy/3391
    # """
    local casks name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew
    name_fancy="Homebrew"
    koopa::update_start "$name_fancy"
    brew analytics off
    brew update >/dev/null
    koopa::h2 'Updating brews.'
    brew upgrade --force-bottle || true
    koopa::h2 'Updating casks.'
    casks="$(koopa::brew_cask_outdated)"
    if [[ -n "$casks" ]]
    then
        koopa::info "${#casks[@]} outdated casks detected."
        koopa::print "${casks[@]}"
        koopa::print "${casks[@]}" \
            | cut -d ' ' -f 1 \
            | xargs brew cask reinstall \
            || true
    fi
    koopa::h2 'Running cleanup.'
    brew cleanup -s || true
    koopa::rm "$(brew --cache)"
    koopa::update_r_config
    koopa::update_success "$name_fancy"
    return 0
}

koopa::macos_install_homebrew() { # {{{1
    # """
    # Install Homebrew.
    # @note Updated 2020-07-17.
    #
    # @seealso
    # https://docs.brew.sh/Installation
    #
    # This script installs Homebrew to '/usr/local' so that you don't need sudo
    # when you run 'brew install'. It is a careful script; it can be run even if
    # you have stuff installed to '/usr/local' already. It tells you exactly
    # what it will do before it does it too. You have to confirm everything it
    # will do before it starts.
    #
    # Alternative install, supporting custom prefix (e.g. /usr/local/homebrew):
    # > mkdir homebrew && \
    # >     curl -L https://github.com/Homebrew/brew/tarball/master \
    # >     | tar xz --strip 1 -C homebrew
    # """
    koopa::assert_has_no_args "$#"
    koopa::exit_if_installed brew
    koopa::assert_is_installed xcode-select
    name_fancy='Homebrew'
    koopa::install_start "$name_fancy"
    koopa::h2 'Installing Xcode command line tools (CLT).'
    xcode-select --install &>/dev/null || true
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        chmod +x "$file"
        "./${file}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::macos_install_homebrew_little_snitch() { # {{{1
    # """
    # Install Little Snitch via Homebrew Cask.
    # @note Updated 2020-07-17.
    # """
    local dmg_file version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed hdiutil open
    version="$(koopa::extract_version "$(brew cask info little-snitch)")"
    dmg_file="$(koopa::homebrew_prefix)/Caskroom/little-snitch/\
${version}/LittleSnitch-${version}.dmg"
    koopa::assert_is_file "$dmg_file"
    hdiutil attach "$dmg_file" &>/dev/null
    open "/Volumes/Little Snitch ${version}/Little Snitch Installer.app"
    return 0
}

koopa::macos_install_homebrew_packages() { # {{{1
    # """
    # Install Homebrew packages using Bundle Brewfile.
    # @note Updated 2020-07-17.
    # """
    local brewfile name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Homebrew Bundle'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed brew
    export HOMEBREW_FORCE_BOTTLE=1
    brewfile="$(koopa::brewfile)"
    koopa::assert_is_file "$brewfile"
    koopa::dl 'Brewfile' "$brewfile"
    brew bundle install --file="$brewfile" --no-lock --no-upgrade
    return 0
}

koopa::macos_uninstall_homebrew() { # {{{1
    # """
    # Uninstall Homebrew.
    # @note Updated 2020-07-17.
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local file name_fancy tmp_dir url
    koopa::exit_if_not_installed brew
    name_fancy='Homebrew'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    # Note that macOS Catalina now uses Zsh instead of Bash by default.
    koopa::h2 'Changing default shell to system Zsh.'
    chsh -s '/bin/zsh' "$USER"
    koopa::h2 "Resetting permissions in '/usr/local'."
    sudo chown -Rhv "$USER" '/usr/local/'*
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='uninstall.sh'
        url="https://raw.githubusercontent.com/Homebrew/install/master/${file}"
        koopa::download "$url"
        chmod +x "$file"
        "./${file}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::uninstall_success "$name_fancy"
    return 0
}

koopa::macos_update_homebrew() { # {{{1
    # """
    # Update Homebrew.
    # @note Updated 2020-07-17.
    # """
    koopa::exit_if_not_installed brew
    koopa::brew_update "$@"
    return 0
}

#!/usr/bin/env bash

koopa::macos_install_homebrew_little_snitch() { # {{{1
    # """
    # Install Little Snitch via Homebrew Cask.
    # @note Updated 2020-12-24.
    # """
    local dmg_file version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_macos
    koopa::assert_is_admin
    koopa::assert_is_installed 'hdiutil' 'open'
    version="$(koopa::extract_version "$(brew info --cask little-snitch)")"
    dmg_file="$(koopa::homebrew_prefix)/Caskroom/little-snitch/\
${version}/LittleSnitch-${version}.dmg"
    koopa::assert_is_file "$dmg_file"
    hdiutil attach "$dmg_file" &>/dev/null
    open "/Volumes/Little Snitch ${version}/Little Snitch Installer.app"
    return 0
}

#!/usr/bin/env bash

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

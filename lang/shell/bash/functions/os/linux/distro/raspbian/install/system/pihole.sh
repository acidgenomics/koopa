#!/usr/bin/env bash

# FIXME Need to wrap this.
# FIXME Need to prefix this with Raspbian.
# FIXME Needs a corresponding updater.
# FIXME Needs a corresponding uninstaller.
# FIXME This also works on Ubuntu, so consider moving.
koopa::install_pihole() { # {{{1
    # """
    # Install Pi-hole.
    # @note Updated 2020-07-14.
    # @seealso
    # - https://pi-hole.net
    # - https://github.com/pi-hole/pi-hole/#one-step-automated-install
    # """
    local file name_fancy tmp_dir url
    koopa::assert_has_no_args "$#"
    name_fancy='Pi-hole'
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='pihole.sh'
        url='https://install.pi-hole.net'
        koopa::download "$url" "$file"
        koopa::chmod 'u+x' "$file"
        "./${file}"
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

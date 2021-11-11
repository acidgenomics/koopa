#!/usr/bin/env bash

# FIXME Need to wrap this.
# FIXME Need to prefix this with Raspbian.
# FIXME This also works on Ubuntu, so consider moving.
# FIXME This needs a corresponding uninstaller.
# FIXME This needs a corresponding updater.
koopa::install_pivpn() { # {{{1
    # """
    # Install PiVPN.
    # @note Updated 2020-07-14.
    # @seealso
    # - https://www.pivpn.io
    # """
    local file name_fancy tmp_dir url
    koopa::assert_has_no_args "$#"
    name_fancy='PiVPN'
    koopa::install_start "$name_fancy"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='pivpn.sh'
        url='https://install.pivpn.io'
        koopa::download "$url" "$file"
        koopa::chmod 'u+x' "$file"
        "./${file}"
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

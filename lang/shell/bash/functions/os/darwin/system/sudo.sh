#!/usr/bin/env bash

koopa::macos_disable_touch_id_sudo() { # {{{1
    # """
    # Disable sudo authentication via Touch ID PAM.
    # @note Updated 2021-03-01.
    # """
    local file
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    file='/etc/pam.d/sudo'
    if [[ ! -f "$file" ]]
    then
        koopa::note "sudo via Touch ID is not enabled."
        return 0
    fi
    koopa::alert "Disabling sudo using Touch ID, defined at '${file}'."
    koopa::rm -S "$file"
    return 0
}

koopa::macos_enable_touch_id_sudo() { # {{{1
    # """
    # Enable sudo authentication via Touch ID PAM.
    # @note Updated 2021-03-01.
    # @seealso
    # - https://davidwalsh.name/touch-sudo
    # - https://news.ycombinator.com/item?id=26302139
    # """
    local file
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    string='auth sufficient pam_tid.so'
    file="/etc/pam.d/sudo"
    if [[ -f "$file" ]]
    then
        koopa::success "sudo using Touch ID is already enabled via '${file}'."
        return 0
    fi
    koopa::sudo_write_string "$string" "$file"
    koopa::success "sudo using Touch ID is enabled via '${file}'."
    return 0
}

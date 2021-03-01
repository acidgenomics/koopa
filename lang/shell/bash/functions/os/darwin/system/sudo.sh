#!/usr/bin/env bash

koopa::macos_disable_touch_id_sudo() { # {{{1
    # """
    # Disable sudo authentication via Touch ID PAM.
    # @note Updated 2021-03-01.
    # """
    local source_file target_file
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    source_file="$(koopa::prefix)/os/macos/etc/pam.d/sudo~orig"
    target_file='/etc/pam.d/sudo'
    if [[ -f "$target_file" ]] && \
        ! grep -q 'pam_tid.so' "$target_file"
    then
        koopa::note "Touch ID not enabled for sudo in '${target_file}'."
        return 0
    fi
    koopa::alert "Disabling Touch ID for sudo, defined at '${target_file}'."
    koopa::cp -S "$source_file" "$target_file"
    sudo chmod 0444 "$target_file"
    koopa::success 'Touch ID disabled for sudo.'
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
    local source_file target_file
    koopa::assert_has_no_args "$#"
    koopa::assert_has_sudo
    source_file="$(koopa::prefix)/os/macos/etc/pam.d/sudo"
    target_file='/etc/pam.d/sudo'
    if [[ -f "$target_file" ]] && grep -q 'pam_tid.so' "$target_file"
    then
        koopa::note "Touch ID already enabled for sudo in '${target_file}'."
        return 0
    fi
    koopa::alert "Enabling Touch ID for sudo in '${target_file}'."
    koopa::assert_is_file "$source_file"
    koopa::cp -S "$source_file" "$target_file"
    sudo chmod 0444 "$target_file"
    koopa::success 'Touch ID enabled for sudo.'
    return 0
}

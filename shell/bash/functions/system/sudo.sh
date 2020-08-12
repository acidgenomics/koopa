#!/usr/bin/env bash

koopa::enable_passwordless_sudo() { # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2020-07-07.
    # """
    local group string sudo_file
    koopa::assert_has_no_args "$#"
    koopa::is_root && return 0
    koopa::assert_has_sudo
    group="$(koopa::admin_group)"
    sudo_file='/etc/sudoers.d/sudo'
    sudo touch "$sudo_file"
    if sudo grep -q "$group" "$sudo_file"
    then
        koopa::success "Passwordless sudo enabled for '${group}' group."
        return 0
    fi
    koopa::info "Updating '${sudo_file}' to include '${group}'."
    string="%${group} ALL=(ALL) NOPASSWD: ALL"
    sudo sh -c "printf '%s\n' '$string' >> '${sudo_file}'"
    sudo chmod -v 0440 "$sudo_file"
    koopa::success "Passwordless sudo enabled for '${group}'."
    return 0
}

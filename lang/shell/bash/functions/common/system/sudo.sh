#!/usr/bin/env bash

koopa::disable_passwordless_sudo() { # {{{1
    # """
    # Disable passwordless sudo access for all admin users.
    # @note Updated 2021-03-01.
    # Consider using 'has_passwordless_sudo' as a check step here.
    # """
    local file
    koopa::assert_is_admin
    file='/etc/sudoers.d/sudo'
    if [[ -f "$file" ]]
    then
        koopa::alert "Removing sudo permission file at '${file}'."
        koopa::rm -S "$file"
    fi
    koopa::alert_success 'Passwordless sudo is disabled.'
    return 0
}

koopa::enable_passwordless_sudo() { # {{{1
    # """
    # Enable passwordless sudo access for all admin users.
    # @note Updated 2021-03-31.
    # """
    local file group string
    koopa::assert_has_no_args "$#"
    koopa::is_root && return 0
    koopa::assert_is_admin
    file='/etc/sudoers.d/sudo'
    group="$(koopa::admin_group)"
    if [[ -f "$file" ]] && sudo grep -q "$group" "$file"
    then
        koopa::alert_success "sudo already configured at '${file}'."
        return 0
    fi
    koopa::alert "Modifying '${file}' to include '${group}'."
    string="%${group} ALL=(ALL) NOPASSWD: ALL"
    koopa::sudo_append_string "$string" "$file"
    sudo chmod 0440 "$file"
    koopa::alert_success "Passwordless sudo enabled for '${group}' \
at '${file}'."
    return 0
}

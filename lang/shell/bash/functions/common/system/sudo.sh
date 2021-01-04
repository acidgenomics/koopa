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

koopa::fix_sudo_setrlimit_error() { # {{{1
    # """
    # Fix bug in recent version of sudo.
    # @note Updated 2020-07-05.
    #
    # This is popping up on Docker builds:
    # sudo: setrlimit(RLIMIT_CORE): Operation not permitted
    #
    # @seealso
    # - https://ask.fedoraproject.org/t/
    #       sudo-setrlimit-rlimit-core-operation-not-permitted/4223
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1773148
    # """
    koopa::assert_has_no_args "$#"
    local source_file target_file
    target_file='/etc/sudo.conf'
    # Ensure we always overwrite for Docker images.
    # Note that Fedora base image contains this file by default.
    if ! koopa::is_docker
    then
        [[ -e "$target_file" ]] && return 0
    fi
    source_file="$(koopa::prefix)/os/linux/etc/sudo.conf"
    sudo cp -v "$source_file" "$target_file"
    return 0
}

#!/usr/bin/env bash

koopa::fedora_dnf() { # {{{1
    # """
    # Use either 'dnf' or 'yum' to manage packages.
    # @note Updated 2021-06-15.
    # """
    local app
    if koopa::is_installed 'dnf'
    then
        app='dnf'
    elif koopa::is_installed 'yum'
    then
        app='yum'
    else
        koopa::stop "Failed to locate package manager (e.g. 'dnf' or 'yum')."
    fi
    sudo "$app" -y "$@"
    return 0
}

koopa::fedora_dnf_delete_repo() { # {{{1
    # """
    # Delete an enabled dnf repo.
    # @note Updated 2021-06-16.
    # """
    local file name
    koopa::assert_has_args "$#"
    for name in "$@"
    do
        file="/etc/yum.repos.d/${name}.repo"
        koopa::assert_is_file "$file"
        koopa::rm -S "$file"
    done
    return 0
}

koopa::fedora_dnf_install() { # {{{1
    koopa::fedora_dnf install "$@"
}

koopa::fedora_dnf_remove() { # {{{1
    koopa::fedora_dnf remove "$@"
}

koopa::fedora_rpm_install() { # {{{1
    # """
    # Install directly from RPM file.
    # @note Updated 2021-06-16.
    # """
    koopa::assert_has_args "$#"
    sudo rpm -v --force --install "$@"
    return 0
}

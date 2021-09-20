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
        koopa::rm --sudo "$file"
    done
    return 0
}

koopa::fedora_dnf_install() { # {{{1
    koopa::fedora_dnf install "$@"
}

koopa::fedora_dnf_remove() { # {{{1
    koopa::fedora_dnf remove "$@"
}

koopa::fedora_install_from_rpm() { # {{{1
    # """
    # Install directly from RPM file.
    # @note Updated 2021-06-17.
    # Allowing passthrough of '--prefix' here.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'rpm'
    sudo rpm -v \
        --force \
        --install \
        --nogpgcheck \
        "$@"
    return 0
}

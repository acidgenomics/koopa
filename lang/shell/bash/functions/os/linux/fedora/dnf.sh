#!/usr/bin/env bash

koopa::fedora_dnf() { # {{{1
    # """
    # Use 'dnf' to manage packages.
    # @note Updated 2021-11-02.
    #
    # Previously defined as 'yum' in versions prior to RHEL 8.
    # """
    local app
    declare -A app=(
        [dnf]="$(koopa::fedora_locate_dnf)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[dnf]}" -y "$@"
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
    # @note Updated 2022-01-28.
    #
    # Allowing passthrough of '--prefix' here.
    # """
    local app
    koopa::assert_has_args "$#"
    declare -A app=(
        [rpm]="$(koopa::fedora_locate_rpm)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[rpm]}" -v \
        --force \
        --install \
        "$@"
    return 0
}

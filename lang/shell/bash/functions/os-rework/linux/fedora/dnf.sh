#!/usr/bin/env bash

koopa_fedora_dnf() {
    # """
    # Use 'dnf' to manage packages.
    # @note Updated 2021-11-02.
    #
    # Previously defined as 'yum' in versions prior to RHEL 8.
    # """
    local app
    declare -A app=(
        [dnf]="$(koopa_fedora_locate_dnf)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[dnf]}" -y "$@"
    return 0
}

koopa_fedora_dnf_delete_repo() {
    # """
    # Delete an enabled dnf repo.
    # @note Updated 2021-06-16.
    # """
    local file name
    koopa_assert_has_args "$#"
    for name in "$@"
    do
        file="/etc/yum.repos.d/${name}.repo"
        koopa_assert_is_file "$file"
        koopa_rm --sudo "$file"
    done
    return 0
}

koopa_fedora_dnf_install() {
    koopa_fedora_dnf install "$@"
}

koopa_fedora_dnf_remove() {
    koopa_fedora_dnf remove "$@"
}

koopa_fedora_install_from_rpm() {
    # """
    # Install directly from RPM file.
    # @note Updated 2022-01-28.
    #
    # Allowing passthrough of '--prefix' here.
    # """
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [rpm]="$(koopa_fedora_locate_rpm)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[rpm]}" -v \
        --force \
        --install \
        "$@"
    return 0
}

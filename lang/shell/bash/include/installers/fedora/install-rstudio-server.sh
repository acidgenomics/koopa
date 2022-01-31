#!/usr/bin/env bash

koopa:::fedora_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Fedora / RHEL / CentOS.
    # @note Updated 2022-01-28.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [arch]="$(koopa::arch)"  # e.g. 'x86_64'.
        [init_dir]='/etc/init.d'
        [os_codename]='centos8'
    )
    if [[ ! -d "${dict[init_dir]}" ]]
    then
        koopa::mkdir --sudo "${dict[init_dir]}"
    fi
    # shellcheck source=/dev/null
    source "$(koopa::installers_prefix)/linux/install-rstudio-server.sh"
    koopa:::linux_install_rstudio_server \
        --file-ext='rpm' \
        --install='koopa::fedora_dnf_install' \
        --os-codename="${dict[os_codename]}" \
        --platform="${dict[arch]}" \
        "$@"
    return 0
}

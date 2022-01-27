#!/usr/bin/env bash

koopa::fedora_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Fedora / RHEL / CentOS.
    # @note Updated 2021-11-02.
    # """
    local dict
    declare -A dict=(
        [arch]="$(koopa::arch)"  # e.g. 'x86_64'.
        [init_dir]='/etc/init.d'
        [os_codename]='centos8'
    )
    if [[ ! -d "${dict[init_dir]}" ]]
    then
        koopa::mkdir --sudo "${dict[init_dir]}"
    fi
    koopa:::linux_install_rstudio_server \
        --file-ext='rpm' \
        --install='koopa::fedora_dnf_install' \
        --os-codename="${dict[os_codename]}" \
        --platform="${dict[arch]}" \
        "$@"
    return 0
}

koopa::fedora_install_rstudio_workbench() { # {{{1
    # """
    # Install RStudio Workbench.
    # @note Updated 2021-06-11.
    # """
    koopa::fedora_install_rstudio_server --workbench "$@"
    return 0
}

koopa::fedora_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-16.
    # """
    koopa::fedora_dnf_remove 'rstudio-server'
}

koopa::fedora_uninstall_rstudio_workbench() { # {{{1
    # """
    # Uninstall RStudio Workbench.
    # @note Updated 2021-06-11.
    # """
    koopa::fedora_uninstall_rstudio_server "$@"
}

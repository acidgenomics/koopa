#!/usr/bin/env bash

# NOTE ARM is not yet supported for this.
koopa::fedora_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Fedora / RHEL / CentOS.
    # @note Updated 2021-06-16.
    # """
    local arch os_codename
    arch="$(koopa::arch)"
    os_codename='centos8'
    koopa::mkdir -S '/etc/init.d'
    koopa:::linux_install_rstudio_server \
        --file-ext='rpm' \
        --install='koopa::fedora_dnf_install' \
        --os-codename="$os_codename" \
        --platform="$arch" \
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

# FIXME Need to ensure repo gets removed here.
# FIXME Check that this works for workbench.
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

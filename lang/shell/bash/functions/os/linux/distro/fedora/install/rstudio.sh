#!/usr/bin/env bash

# NOTE ARM is not yet supported for this.
koopa::fedora_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Fedora / RHEL / CentOS.
    # @note Updated 2021-03-30.
    # """
    local arch os_codename
    arch="$(koopa::arch)"
    os_codename='centos8'
    koopa::mkdir -S '/etc/init.d'
    koopa:::linux_install_rstudio_server \
        --file-ext='rpm' \
        --install='sudo dnf -y install' \
        --os-codename="$os_codename" \
        --platform="$arch" \
        "$@"
    return 0
}

koopa::fedora_install_rstudio_server_pro() { # {{{1
    koopa::fedora_install_rstudio_server --pro "$@"
    return 0
}

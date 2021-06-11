#!/usr/bin/env bash

koopa::debian_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2021-04-26.
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    # """
    local arch os_codename
    koopa::assert_is_installed 'gdebi' 'sudo'
    arch="$(koopa::arch)"
    case "$arch" in
        x86_64)
            arch='amd64'
            ;;
    esac
    os_codename="$(koopa::os_codename)"
    case "$os_codename" in
        buster|focal)
            os_codename='bionic'
            ;;
        bionic)
            ;;
        *)
            koopa::stop "Unsupported OS version: '${os_codename}'."
            ;;
    esac
    koopa:::linux_install_rstudio_server \
        --file-ext='deb' \
        --install='sudo gdebi --non-interactive' \
        --os-codename="$os_codename" \
        --platform="$arch" \
        "$@"
    return 0
}

koopa::debian_install_rstudio_server_workbench() { # {{{1
    koopa::debian_install_rstudio_server --workbench "$@"
    return 0
}

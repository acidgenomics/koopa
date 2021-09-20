#!/usr/bin/env bash

koopa::debian_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2021-09-20.
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
        'bullseye' | \
        'buster' | \
        'focal')
            os_codename='bionic'
            ;;
        'bionic')
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

koopa::debian_install_rstudio_workbench() { # {{{1
    # """
    # Install RStudio Workbench.
    # @note Updated 2021-06-11.
    # """
    koopa::debian_install_rstudio_server --workbench "$@"
    return 0
}

koopa::debian_uninstall_rstudio_server() { # {{{1
    # """
    # Uninstall RStudio Server.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'rstudio-server'
    return 0
}

koopa::debian_uninstall_rstudio_workbench() { # {{{1
    # """
    # Uninstall RStudio Workbench.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_uninstall_rstudio_server "$@"
}

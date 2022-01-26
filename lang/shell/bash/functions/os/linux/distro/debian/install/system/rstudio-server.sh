#!/usr/bin/env bash

koopa::debian_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2021-11-02.
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    # """
    local app dict
    declare -A app=(
        [gdebi]="$(koopa::debian_locate_gdebi)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa::arch2)"  # e.g. 'amd64'.
        [os_codename]='bionic'
    )
    koopa:::linux_install_rstudio_server \
        --file-ext='deb' \
        --install="${app[sudo]} ${app[gdebi]} --non-interactive" \
        --os-codename="${dict[os_codename]}" \
        --platform="${dict[arch]}" \
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

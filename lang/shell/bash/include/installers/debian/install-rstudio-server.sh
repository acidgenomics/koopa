#!/usr/bin/env bash

# FIXME How to passthrough workbench and version here?

# FIXME Expecting this URL:
# https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.2-382-amd64.deb

# Currently returning:
# https://download2.rstudio.org/server/bionic/amd64/rstudio-server-2021.09.2%2B382-amd64.deb

koopa:::debian_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2022-01-28.
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
    # shellcheck source=/dev/null
    source "$(koopa::koopa_prefix)/lang/shell/bash/include/installers/\
linux/install-rstudio-server.sh"
    koopa:::linux_install_rstudio_server \
        --file-ext='deb' \
        --install="${app[sudo]} ${app[gdebi]} --non-interactive" \
        --os-codename="${dict[os_codename]}" \
        --platform="${dict[arch]}" \
        "$@"
    return 0
}

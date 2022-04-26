#!/usr/bin/env bash

linux_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Debian / Ubuntu.
    # @note Updated 2022-04-26.
    #
    # Verify install:
    # > sudo rstudio-server stop
    # > sudo rstudio-server verify-installation
    # > sudo rstudio-server start
    # > sudo rstudio-server status
    # """
    local app dict
    declare -A app=(
        [gdebi]="$(koopa_debian_locate_gdebi)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [arch]="$(koopa_arch2)" # e.g. 'amd64'.
        [os_codename]='bionic'
    )
    # shellcheck source=/dev/null
    source "$(koopa_installers_prefix)/linux/system/install-rstudio-server.sh"
    linux_install_rstudio_server \
        --file-ext='deb' \
        --install="${app[sudo]} ${app[gdebi]} --non-interactive" \
        --os-codename="${dict[os_codename]}" \
        --platform="${dict[arch]}" \
        "$@"
    return 0
}

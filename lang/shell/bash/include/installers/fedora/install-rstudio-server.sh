#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

fedora_install_rstudio_server() { # {{{1
    # """
    # Install RStudio Server on Fedora / RHEL / CentOS.
    # @note Updated 2022-01-28.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A dict=(
        [arch]="$(koopa_arch)" # e.g. 'x86_64'.
        [init_dir]='/etc/init.d'
        [os_codename]='centos8'
    )
    if [[ ! -d "${dict[init_dir]}" ]]
    then
        koopa_mkdir --sudo "${dict[init_dir]}"
    fi
    # shellcheck source=/dev/null
    source "$(koopa_installers_prefix)/linux/install-rstudio-server.sh"
    linux_install_rstudio_server \
        --file-ext='rpm' \
        --install='koopa_fedora_dnf_install' \
        --os-codename="${dict[os_codename]}" \
        --platform="${dict[arch]}" \
        "$@"
    return 0
}

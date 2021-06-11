#!/usr/bin/env bash

koopa::debian_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2021-06-11.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt
    #
    # Required packages:
    # - apt-transport-https
    # - ca-certificates
    # - curl
    # - gnupg
    # - lsb-release
    #
    # Automated script:
    # > curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    # """
    local name_fancy
    name_fancy='Azure CLI'
    koopa::install_start "$name_fancy"
    if koopa::is_installed 'az'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::debian_apt_add_azure_cli_repo
    koopa::debian_apt_install 'azure-cli'
    koopa::install_success "$name_fancy"
    return 0
}

koopa::debian_uninstall_azure_cli() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2021-06-11.
    # """
    local apt_file name_fancy
    name_fancy='Azure CLI'
    koopa::uninstall_start "$name_fancy"
    koopa::debian_apt_remove 'azure-cli'
    # FIXME Convert this to 'koopa::debian_apt_delete_azure_cli_repo'.
    apt_file='/etc/apt/sources.list.d/azure-cli.list'
    koopa::rm -S "$apt_file"
    koopa::uninstall_success "$name_fancy"
}

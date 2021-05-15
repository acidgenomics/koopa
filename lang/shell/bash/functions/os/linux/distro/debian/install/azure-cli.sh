#!/usr/bin/env bash

koopa::debian_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2020-07-30.
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
    koopa::is_installed az && return 0
    name_fancy='Azure CLI'
    koopa::install_start "$name_fancy"
    koopa::apt_add_azure_cli_repo
    koopa::apt_install azure-cli
    koopa::install_success "$name_fancy"
    return 0
}


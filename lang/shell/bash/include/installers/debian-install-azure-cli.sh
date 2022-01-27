#!/usr/bin/env bash

koopa:::debian_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2022-01-27.
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
    koopa::debian_apt_add_azure_cli_repo
    koopa::debian_apt_install 'azure-cli'
    return 0
}

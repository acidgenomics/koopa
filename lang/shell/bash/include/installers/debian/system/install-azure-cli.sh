#!/usr/bin/env bash

main() { # {{{1
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
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_azure_cli_repo
    koopa_debian_apt_install 'azure-cli'
    return 0
}

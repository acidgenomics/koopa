#!/usr/bin/env bash

main() {
    # """
    # Install Azure CLI.
    # @note Updated 2022-07-15.
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
    koopa_link_in_bin '/usr/bin/az' 'az'
    return 0
}

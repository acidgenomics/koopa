#!/usr/bin/env bash

koopa:::fedora_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    koopa::assert_has_no_args "$#"
    koopa::fedora_import_azure_cli_key
    koopa::fedora_add_azure_cli_repo
    koopa::fedora_dnf_install 'azure-cli'
    return 0
}

#!/usr/bin/env bash

main() {
    # """
    # Install Azure CLI.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_import_azure_cli_key
    koopa_fedora_add_azure_cli_repo
    koopa_fedora_dnf_install 'azure-cli'
    return 0
}

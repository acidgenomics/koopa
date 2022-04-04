#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

fedora_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_fedora_import_azure_cli_key
    koopa_fedora_add_azure_cli_repo
    koopa_fedora_dnf_install 'azure-cli'
    return 0
}

#!/usr/bin/env bash

koopa:::fedora_uninstall_azure_cli() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2022-01-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::fedora_dnf_remove 'azure-cli'
    koopa::fedora_dnf_delete_repo 'azure-cli'
    return 0
}

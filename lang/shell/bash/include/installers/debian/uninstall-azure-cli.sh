#!/usr/bin/env bash

koopa:::debian_uninstall_azure_cli() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2021-11-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    koopa::debian_apt_remove 'azure-cli'
    koopa::debian_apt_delete_repo 'azure-cli'
    return 0
}

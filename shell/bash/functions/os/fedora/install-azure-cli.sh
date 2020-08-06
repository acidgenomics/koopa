#!/usr/bin/env bash

# FIXME Rename all instances of 'yum' to 'dnf'.
koopa::fedora_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2020-08-06.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    koopa::is_installed az && return 0
    name_fancy='Azure CLI'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed python3
    koopa::yum_import_azure_cli_key
    koopa::yum_add_azure_cli_repo
    sudo dnf -y install azure-cli
    koopa::install_success "$name_fancy"
    return 0
}

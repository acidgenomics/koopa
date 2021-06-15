#!/usr/bin/env bash

koopa::fedora_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2021-06-15.
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    local name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Azure CLI'
    if koopa::is_installed 'az'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::install_start "$name_fancy"
    koopa::fedora_import_azure_cli_key
    koopa::fedora_add_azure_cli_repo
    koopa::fedora_dnf_install 'azure-cli'
    koopa::install_success "$name_fancy"
    return 0
}

koopa::fedora_uninstall_azure_cli() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2021-06-15.
    # """
    koopa::fedora_dnf_remove 'azure-cli'
    # FIXME Need to delete the repo.
    # FIXME Mimic this after Debian approach.
    # /etc/yum.repos.d/azure-cli.repo
}

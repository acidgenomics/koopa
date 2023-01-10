#!/usr/bin/env bash

koopa_debian_apt_add_azure_cli_repo() {
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2023-01-10.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_microsoft_key
    koopa_debian_apt_add_repo \
        --component='main' \
        --distribution="$(koopa_debian_os_codename)" \
        --key-name='microsoft' \
        --name='azure-cli' \
        --url='https://packages.microsoft.com/repos/azure-cli/'
    return 0
}

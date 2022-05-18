#!/usr/bin/env bash

koopa_debian_apt_add_azure_cli_repo() {
    # """
    # Add Microsoft Azure CLI apt repo.
    # @note Updated 2021-11-09.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_microsoft_key
    koopa_debian_apt_add_repo \
        --name-fancy='Microsoft Azure CLI' \
        --name='azure-cli' \
        --key-name='microsoft' \
        --url='https://packages.microsoft.com/repos/azure-cli/' \
        --distribution="$(koopa_os_codename)" \
        --component='main'
    return 0
}

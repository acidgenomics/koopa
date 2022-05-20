#!/usr/bin/env bash

koopa_fedora_import_azure_cli_key() {
    # """
    # Import the Microsoft Azure CLI public key.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [rpm]="$(koopa_fedora_locate_rpm)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [key]='https://packages.microsoft.com/keys/microsoft.asc'
    )
    "${app[sudo]}" "${app[rpm]}" --import "${dict[key]}"
    return 0
}

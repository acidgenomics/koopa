#!/usr/bin/env bash

koopa_debian_apt_add_microsoft_key() {
    # """
    # Add the Microsoft GPG key (for Azure CLI).
    # @note Updated 2021-11-09.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Microsoft' \
        --name='microsoft' \
        --url='https://packages.microsoft.com/keys/microsoft.asc'
    return 0
}

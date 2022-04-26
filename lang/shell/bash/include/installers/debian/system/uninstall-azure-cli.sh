#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2021-11-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_remove 'azure-cli'
    koopa_debian_apt_delete_repo 'azure-cli'
    return 0
}

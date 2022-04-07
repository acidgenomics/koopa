#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
    # """
    # Uninstall Azure CLI.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_dnf_remove 'azure-cli'
    koopa_fedora_dnf_delete_repo 'azure-cli'
    return 0
}

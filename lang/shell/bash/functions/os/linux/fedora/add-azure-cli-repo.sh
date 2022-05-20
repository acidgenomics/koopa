#!/usr/bin/env bash

koopa_fedora_add_azure_cli_repo() {
    # """
    # Add Microsoft Azure CLI repo.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [file]='/etc/yum.repos.d/azure-cli.repo'
    )
    [[ -f "${dict[file]}" ]] && return 0
    "${app[sudo]}" "${app[tee]}" "${dict[file]}" >/dev/null << END
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
END
    return 0
}

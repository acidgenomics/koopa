#!/usr/bin/env bash

koopa::fedora_install_azure_cli() { # {{{1
    # """
    # Install Azure CLI.
    # @note Updated 2020-07-16.
    #
    # Note that recommended 'yumdownloader' approach doesn't work for Amazon
    # Linux, so get the corresponding RHEL 7 RPM file from
    # packages.microsoft.com instead.
    #
    # @seealso
    # - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum
    # """
    local file name name_fancy tmp_dir url version
    koopa::assert_has_no_args "$#"
    koopa::exit_if_installed az
    name='azure-cli'
    name_fancy='Azure CLI'
    koopa::install_start "$name_fancy"
    koopa::assert_is_installed python3
    koopa::yum_import_azure_cli_key
    koopa::yum_add_azure_cli_repo
    if koopa::is_rhel_7
    then
        # Install on RHEL 7.6 or other systems without Python 3.
        tmp_dir="$(koopa::tmp_dir)"
        (
            version="$(koopa::variable "$name")"
            file="${name}-${version}-1.el7.x86_64.rpm"
            url="https://packages.microsoft.com/yumrepos/${name}/${file}"
            koopa::download "$url"
            sudo rpm -ivh --nodeps "$file"
        )
        koopa::rm "$tmp_dir"
    else
        sudo dnf -y install azure-cli
    fi
    koopa::install_success "$name_fancy"
    return 0
}

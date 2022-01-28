#!/usr/bin/env bash

koopa::fedora_install_azure_cli() { # {{{1
    koopa::install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='Fedora base system' \
        --name='base-system' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_install_google_cloud_sdk() { # {{{1
    koopa::install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_install_oracle_instant_client() { # {{{1
    koopa::install_app \
        --name-fancy='Oracle Instant Client' \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_install_rstudio_server() { # {{{1
    koopa::install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

# FIXME Rework this, with same consistency as Debian.
# FIXME Need to rework the version and name passthrough here.
koopa::fedora_install_rstudio_workbench() { # {{{1
    koopa::fedora_install_rstudio_server --workbench "$@"
    return 0
}

koopa::fedora_uninstall_azure_cli() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_uninstall_google_cloud_sdk() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_uninstall_oracle_instant_client() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Oracle Instant Client' \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa::fedora_uninstall_rstudio_server() { # {{{1
    koopa::uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

# FIXME Rework this, same as Debian.
koopa::fedora_uninstall_rstudio_workbench() { # {{{1
    koopa::fedora_uninstall_rstudio_server "$@"
}

# FIXME This technically isn't a wrapper, so rethink...
koopa::fedora_update_system() { # {{{1
    # """
    # Update Fedora.
    # @note Updated 2021-11-18.
    # """
    koopa::assert_has_no_args "$#"
    koopa::fedora_dnf update
    koopa::update_system
    return 0
}

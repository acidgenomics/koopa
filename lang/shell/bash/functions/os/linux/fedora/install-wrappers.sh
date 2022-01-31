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

koopa::fedora_install_rstudio_workbench() { # {{{1
    koopa::install_app \
        --installer='rstudio-server' \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='fedora' \
        --system \
        "$@"
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

koopa::fedora_uninstall_rstudio_workbench() { # {{{1
    koopa::uninstall_app \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='fedora' \
        --system \
        --uninstaller='rstudio-server' \
        "$@"
}

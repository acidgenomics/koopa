#!/usr/bin/env bash

# System ================================================================== {{{1

# azure-cli --------------------------------------------------------------- {{{2

koopa_fedora_install_azure_cli() { # {{{3
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_azure_cli() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}

# base-system ------------------------------------------------------------- {{{2

koopa_fedora_install_base_system() { # {{{3
    koopa_install_app \
        --name-fancy='Fedora base system' \
        --name='base-system' \
        --platform='fedora' \
        --system \
        "$@"
}

# google-cloud-sdk -------------------------------------------------------- {{{2

koopa_fedora_install_google_cloud_sdk() { # {{{3
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_google_cloud_sdk() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
}

# oracle-instant-client --------------------------------------------------- {{{2

koopa_fedora_install_oracle_instant_client() { # {{{3
    koopa_install_app \
        --name-fancy='Oracle Instant Client' \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_oracle_instant_client() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Oracle Instant Client' \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

# rstudio-server ---------------------------------------------------------- {{{2

koopa_fedora_install_rstudio_server() { # {{{3
    koopa_install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_rstudio_server() { # {{{3
    koopa_uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}


# rstudio-workbench ------------------------------------------------------- {{{2

koopa_fedora_install_rstudio_workbench() { # {{{3
    koopa_install_app \
        --installer='rstudio-server' \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_rstudio_workbench() { # {{{3
    koopa_uninstall_app \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='fedora' \
        --system \
        --uninstaller='rstudio-server' \
        "$@"
}

# shiny-server ------------------------------------------------------------ {{{2

koopa_fedora_install_shiny_server() { # {{{3
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_shiny_server() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}

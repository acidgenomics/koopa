#!/usr/bin/env bash

# Shared ================================================================== {{{1

# bcbio-nextgen-vm -------------------------------------------------------- {{{2

koopa_debian_install_bcbio_nextgen_vm() { # {{{3
    koopa_install_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

koopa_debian_uninstall_bcbio_nextgen_vm() { # {{{3
    koopa_uninstall_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

# r-devel ----------------------------------------------------------------- {{{2

koopa_debian_install_r_devel() { # {{{3
    koopa_install_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --platform='debian' \
        "$@"
}

koopa_debian_uninstall_r_devel() { # {{{3
    koopa_uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --platform='debian' \
        "$@"
}

# System ================================================================== {{{1

# azure-cli --------------------------------------------------------------- {{{2

koopa_debian_install_azure_cli() { # {{{3
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_azure_cli() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

# base-system ------------------------------------------------------------- {{{2

koopa_debian_install_base_system() { # {{{3
    koopa_install_app \
        --name-fancy='Debian base system' \
        --name='base-system' \
        --platform='debian' \
        --system \
        "$@"
}

# docker ------------------------------------------------------------------ {{{2

koopa_debian_install_docker() { # {{{3
    koopa_install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_docker() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

# google-cloud-sdk -------------------------------------------------------- {{{2

koopa_debian_install_google_cloud_sdk() { # {{{3
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_google_cloud_sdk() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

# llvm -------------------------------------------------------------------- {{{2

koopa_debian_install_llvm() { # {{{3
    koopa_install_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_llvm() { # {{{3
    koopa_uninstall_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

# node-binary ------------------------------------------------------------- {{{2

koopa_debian_install_node_binary() { # {{{3
    koopa_install_app \
        --name-fancy='Node.js (binary)' \
        --name='node-binary' \
        --platform='debian' \
        --system \
        "$@"
}

# FIXME Need to add Node binary uninstaller.

# pandoc ------------------------------------------------------------------ {{{2

koopa_debian_install_pandoc_binary() { # {{{3
    koopa_install_app \
        --installer='pandoc-binary' \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_pandoc_binary() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        --uninstaller='pandoc-binary' \
        "$@"
}

# r-binary ---------------------------------------------------------------- {{{2

koopa_debian_install_r_binary() { # {{{3
    koopa_install_app \
        --installer='r-binary' \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}

koopa_debian_uninstall_r_binary() { # {{{3
    koopa_uninstall_app \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --uninstaller='r-binary' \
        "$@"
}

# rstudio-server ---------------------------------------------------------- {{{2

koopa_debian_install_rstudio_server() { # {{{3
    koopa_install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_rstudio_server() { # {{{3
    koopa_uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

# rstudio-workbench ------------------------------------------------------- {{{2

koopa_debian_install_rstudio_workbench() { # {{{3
    koopa_install_app \
        --installer='rstudio-server' \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_rstudio_workbench() { # {{{3
    koopa_uninstall_app \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='debian' \
        --system \
        --uninstaller='rstudio-server' \
        "$@"
}

# shiny-server ------------------------------------------------------------ {{{2

koopa_debian_install_shiny_server() { # {{{3
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_shiny_server() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

# wine -------------------------------------------------------------------- {{{2

koopa_debian_install_wine() { # {{{3
    koopa_install_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_wine() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

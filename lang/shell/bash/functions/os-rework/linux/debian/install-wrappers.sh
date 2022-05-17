#!/usr/bin/env bash

# Shared ================================================================== {{{1

# bcbio-nextgen-vm -------------------------------------------------------- {{{2

koopa_debian_install_bcbio_nextgen_vm() {
    koopa_install_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

koopa_debian_uninstall_bcbio_nextgen_vm() {
    koopa_uninstall_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

# System ================================================================== {{{1

# azure-cli --------------------------------------------------------------- {{{2

koopa_debian_install_azure_cli() {
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_azure_cli() {
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

# base-system ------------------------------------------------------------- {{{2

koopa_debian_install_base_system() {
    koopa_install_app \
        --name-fancy='Debian base system' \
        --name='base-system' \
        --platform='debian' \
        --system \
        "$@"
}

# docker ------------------------------------------------------------------ {{{2

koopa_debian_install_docker() {
    koopa_install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_docker() {
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

# google-cloud-sdk -------------------------------------------------------- {{{2

koopa_debian_install_google_cloud_sdk() {
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_google_cloud_sdk() {
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

# llvm -------------------------------------------------------------------- {{{2

koopa_debian_install_llvm() {
    koopa_install_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_llvm() {
    koopa_uninstall_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

# node-binary ------------------------------------------------------------- {{{2

koopa_debian_install_nodesource_node_binary() {
    koopa_install_app \
        --name-fancy='NodeSource Node.js' \
        --name='nodesource-node-binary' \
        --platform='debian' \
        --system \
        "$@"
}

# FIXME Need to add Node binary uninstaller.

# pandoc ------------------------------------------------------------------ {{{2

koopa_debian_install_pandoc_binary() {
    koopa_install_app \
        --installer='pandoc-binary' \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_pandoc_binary() {
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        --uninstaller='pandoc-binary' \
        "$@"
}

# r-binary ---------------------------------------------------------------- {{{2

koopa_debian_install_r_binary() {
    koopa_install_app \
        --installer='r-binary' \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}

koopa_debian_uninstall_r_binary() {
    koopa_uninstall_app \
        --name-fancy='R CRAN binary' \
        --name='r' \
        --platform='debian' \
        --system \
        --uninstaller='r-binary' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
}

# rstudio-server ---------------------------------------------------------- {{{2

koopa_debian_install_rstudio_server() {
    koopa_install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_rstudio_server() {
    koopa_uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

# shiny-server ------------------------------------------------------------ {{{2

koopa_debian_install_shiny_server() {
    koopa_install_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_shiny_server() {
    koopa_uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

# wine -------------------------------------------------------------------- {{{2

koopa_debian_install_wine() {
    koopa_install_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_wine() {
    koopa_uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

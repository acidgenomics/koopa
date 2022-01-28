#!/usr/bin/env bash

koopa::debian_install_azure_cli() { # {{{1
    koopa::install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='Debian base system' \
        --name='base-system' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_bcbio_nextgen_vm() { # {{{1
    koopa::install_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        --platform='debian' \
        "$@"
}

koopa::debian_install_docker() { # {{{1
    koopa::install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_google_cloud_sdk() { # {{{1
    koopa::install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_llvm() { # {{{1
    koopa::install_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_node() { # {{{1
    koopa::install_app \
        --name-fancy='Node.js' \
        --name='node' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_pandoc() { # {{{1
    koopa::install_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_install_r_devel() { # {{{1
    koopa::install_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --no-link \
        --platform='debian' \
        "$@"
}

koopa::debian_install_wine() { # {{{1
    koopa::install_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_azure_cli() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_bcbio_nextgen_vm() { # {{{1
    koopa::uninstall_app \
        --name='bcbio-nextgen-vm' \
        --no-link \
        "$@"
}

koopa::debian_uninstall_docker() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_google_cloud_sdk() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_llvm() { # {{{1
    koopa::uninstall_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_pandoc() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_r_devel() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --no-link \
        --platform='debian' \
        "$@"
}

koopa::debian_uninstall_shiny_server() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa::debian_uninstall_wine() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

#!/usr/bin/env bash

koopa_debian_install_azure_cli() { # {{{1
    koopa_install_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_base_system() { # {{{1
    koopa_install_app \
        --name-fancy='Debian base system' \
        --name='base-system' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_bcbio_nextgen_vm() { # {{{1
    koopa_install_app \
        --name='bcbio-nextgen-vm' \
        --platform='debian' \
        "$@"
}

koopa_debian_install_docker() { # {{{1
    koopa_install_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_google_cloud_sdk() { # {{{1
    koopa_install_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_llvm() { # {{{1
    koopa_install_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_pandoc_binary() { # {{{1
    koopa_install_app \
        --name-fancy='Pandoc' \
        --name='pandoc-binary' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_r_binary() { # {{{1
    koopa_install_app \
        --name-fancy='R CRAN binary' \
        --name='r-binary' \
        --platform='debian' \
        --system \
        --version-key='r' \
        "$@"
}

koopa_debian_install_r_devel() { # {{{1
    koopa_install_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --platform='debian' \
        "$@"
}

koopa_debian_install_rstudio_server() { # {{{1
    koopa_install_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_rstudio_workbench() { # {{{1
    koopa_install_app \
        --installer='rstudio-server' \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_install_wine() { # {{{1
    koopa_install_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_azure_cli() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Azure CLI' \
        --name='azure-cli' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_bcbio_nextgen_vm() { # {{{1
    koopa_uninstall_app \
        --name='bcbio-nextgen-vm' \
        "$@"
}

koopa_debian_uninstall_docker() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_google_cloud_sdk() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_llvm() { # {{{1
    koopa_uninstall_app \
        --name-fancy='LLVM' \
        --name='llvm' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_pandoc_binary() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc-binary' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_r_binary() { # {{{1
    koopa_uninstall_app \
        --name-fancy='R CRAN binary' \
        --name='r-binary' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_r_devel() { # {{{1
    koopa_uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --platform='debian' \
        "$@"
}

koopa_debian_uninstall_rstudio_server() { # {{{1
    koopa_uninstall_app \
        --name-fancy='RStudio Server' \
        --name='rstudio-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_rstudio_workbench() { # {{{1
    koopa_uninstall_app \
        --name-fancy='RStudio Workbench' \
        --name='rstudio-workbench' \
        --platform='debian' \
        --system \
        --uninstaller='rstudio-server' \
        "$@"
}

koopa_debian_uninstall_shiny_server() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Shiny Server' \
        --name='shiny-server' \
        --platform='debian' \
        --system \
        "$@"
}

koopa_debian_uninstall_wine() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Wine' \
        --name='wine' \
        --platform='debian' \
        --system \
        "$@"
}

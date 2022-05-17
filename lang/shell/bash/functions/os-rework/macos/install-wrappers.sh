#!/usr/bin/env bash

# Shared ================================================================== {{{1

# aws-cli ----------------------------------------------------------------- {{{2

koopa_macos_install_aws_cli() {
    koopa_install_app \
        --link-in-bin='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='macos' \
        "$@"
}

# neovim-binary ----------------------------------------------------------- {{{2

koopa_macos_install_neovim_binary() {
    koopa_install_app \
        --installer='neovim-binary' \
        --link-in-bin='bin/nvim' \
        --name-fancy='Neovim' \
        --name='neovim' \
        --platform='macos' \
        "$@"
}

# System ================================================================== {{{1

# adobe-creative-cloud ---------------------------------------------------- {{{2

koopa_macos_uninstall_adobe_creative_cloud() {
    koopa_uninstall_app \
        --name-fancy='Adobe Creative Cloud' \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

# cisco-webex ------------------------------------------------------------- {{{2

koopa_macos_uninstall_cisco_webex() {
    koopa_uninstall_app \
        --name-fancy='Cisco WebEx' \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}

# defaults ---------------------------------------------------------------- {{{2

koopa_macos_update_defaults() {
    koopa_update_app \
        --name-fancy='macOS defaults' \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}

# microsoft-onedrive ------------------------------------------------------ {{{2

koopa_macos_uninstall_microsoft_onedrive() {
    koopa_uninstall_app \
        --name-fancy='Microsoft OneDrive' \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}

# oracle-java ------------------------------------------------------------- {{{2

koopa_macos_uninstall_oracle_java() {
    koopa_uninstall_app \
        --name-fancy='Oracle Java' \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}

# python-binary ----------------------------------------------------------- {{{2

koopa_macos_install_python_binary() {
    koopa_install_app \
        --installer='python-binary' \
        --link-in-bin='bin/python3' \
        --name-fancy='Python' \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}

koopa_macos_uninstall_python_binary() {
    koopa_uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        --uninstaller='python-binary' \
        --unlink-in-bin='python3' \
        "$@"
}

# r-binary ---------------------------------------------------------------- {{{2

koopa_macos_install_r_binary() {
    koopa_install_app \
        --installer='r-binary' \
        --link-in-bin='bin/R' \
        --link-in-bin='bin/Rscript' \
        --name-fancy='R' \
        --name='r' \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        "$@"
}

koopa_macos_uninstall_r_binary() {
    koopa_uninstall_app \
        --name-fancy='R' \
        --name='r' \
        --platform='macos' \
        --system \
        --uninstaller='r-binary' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
}

# r-gfortran -------------------------------------------------------------- {{{2

koopa_macos_install_r_gfortran() {
    koopa_install_app \
        --name-fancy='R gfortran' \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}

koopa_macos_uninstall_r_gfortran() {
    koopa_uninstall_app \
        --name-fancy='R gfortran' \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}

# r-openmp ---------------------------------------------------------------- {{{2

koopa_macos_install_r_openmp() {
    koopa_install_app \
        --name-fancy='R OpenMP' \
        --name='r-openmp' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_r_gfortran() {
    koopa_uninstall_app \
        --name-fancy='R OpenMP' \
        --name='r-openmp' \
        --platform='macos' \
        --system \
        "$@"
}

# ringcentral ------------------------------------------------------------- {{{2

koopa_macos_uninstall_ringcentral() {
    koopa_uninstall_app \
        --name-fancy='RingCentral' \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}

# system ------------------------------------------------------------------ {{{2

koopa_macos_update_system() {
    koopa_update_app \
        --name-fancy='macOS system' \
        --name='system' \
        --platform='macos' \
        --system \
        "$@"
}

# xcode-clt --------------------------------------------------------------- {{{2

koopa_macos_install_xcode_clt() {
    koopa_install_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_xcode_clt() {
    koopa_uninstall_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

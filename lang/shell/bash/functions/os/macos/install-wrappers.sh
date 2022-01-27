#!/usr/bin/env bash

koopa::macos_install_python_framework() { # {{{1
    koopa::install_app \
        --installer='python-framework' \
        --name-fancy='Python framework' \
        --name='python' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_install_r_cran_gfortran() { # {{{1
    koopa::install_app \
        --name-fancy='R CRAN gfortran' \
        --name='r-cran-gfortran' \
        --platform='macos' \
        --prefix="$(koopa::macos_gfortran_prefix)" \
        --system \
        "$@"
}

koopa::macos_install_r_framework() { # {{{1
    koopa::install_app \
        --installer='r-framework' \
        --name-fancy='R framework' \
        --name='r' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_install_xcode_clt() { # {{{1
    koopa::install_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_adobe_creative_cloud() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Adobe Creative Cloud' \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_cisco_webex() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Cisco WebEx' \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_microsoft_onedrive() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Microsoft OneDrive' \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_oracle_java() { # {{{
    koopa::uninstall_app \
        --name-fancy='Oracle Java' \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_python_framework() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Python framework' \
        --name='python' \
        --platform='macos' \
        --system \
        --uninstaller='python-framework' \
        "$@"
}

koopa::macos_uninstall_r_cran_gfortran() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R CRAN gfortran' \
        --name='r-cran-gfortran' \
        --platform='macos' \
        --prefix="$(koopa::macos_gfortran_prefix)" \
        --system \
        "$@"
}

koopa::macos_uninstall_r_framework() { # {{{1
    koopa::uninstall_app \
        --name-fancy='R framework' \
        --name='r' \
        --platform='macos' \
        --system \
        --uninstaller='r-framework' \
        "$@"
}

koopa::macos_uninstall_ringcentral() { # {{{1
    koopa::uninstall_app \
        --name-fancy='RingCentral' \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_uninstall_xcode_clt() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_update_google_cloud_sdk() { # {{{1
    koopa::update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_update_defaults() { # {{{1
    koopa::update_app \
        --name-fancy='macOS defaults' \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}

koopa::macos_update_system() { # {{{1
    koopa::update_app \
        --name-fancy='macOS system' \
        --name='system' \
        --platform='macos' \
        --system \
        "$@"
}

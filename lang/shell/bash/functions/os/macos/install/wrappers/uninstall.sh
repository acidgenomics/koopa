#!/usr/bin/env bash

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

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

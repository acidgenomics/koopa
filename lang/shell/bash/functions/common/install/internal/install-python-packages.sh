#!/usr/bin/env bash

koopa:::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2022-01-26.
    # """
    local pkgs
    koopa::assert_has_no_args "$#"
    # Install essential defaults first.
    pkgs=(
        'pip'
        'setuptools'
        'wheel'
    )
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    koopa::alert_info 'Ensuring essential defaults are version pinned.'
    koopa::python_pip_install "${pkgs[@]}"
    # Now we can install additional recommended extras.
    pkgs=(
        'black'
        'bpytop'
        'flake8'
        'glances'
        'pip2pi'
        'pipx'
        'pyflakes'
        'pylint'
        'pynvim'
        'pytaglib'
        'pytest'
        'ranger-fm'
    )
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    koopa::python_pip_install "${pkgs[@]}"
    return 0
}

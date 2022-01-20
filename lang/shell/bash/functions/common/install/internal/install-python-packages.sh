#!/usr/bin/env bash

koopa:::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-12-07.
    # """
    local pkgs
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
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
    fi
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    koopa::python_pip_install "${pkgs[@]}"
    return 0
}

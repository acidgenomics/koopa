#!/usr/bin/env bash

koopa:::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-11-19.
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
            'Cython'
            'black'         # homebrew
            'bpytop'        # homebrew
            'flake8'        # homebrew
            'glances'       # homebrew
            'isort'
            'pip2pi'
            'pipx'          # homebrew
            'psutil'
            'pyflakes'
            'pylint'        # homebrew
            'pynvim'
            # > 'pytaglib'      # Failed to install on Python 3.10.
            'pytest'
            'ranger-fm'     # homebrew
            'six'
        )
    fi
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    koopa::python_pip_install "${pkgs[@]}"
    return 0
}

#!/usr/bin/env bash

koopa:::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2022-02-23.
    # """
    local app pkgs
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa::locate_brew 2>/dev/null || true)"
    )
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
    pkgs=('pipx')
    if [[ ! -x "${app[brew]}" ]]
    then
        pkgs+=(
            'black'
            'bpytop'
            'flake8'
            'glances'
            'pyflakes'
            'pylint'
            'pytest'
            'ranger-fm'
        )
    fi
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    koopa::python_pip_install "${pkgs[@]}"
    return 0
}

#!/usr/bin/env bash

# FIXME pip3 is currently returning 21.2.4 even though 22.0.3 is installed.
# Python package management is seriously annoying...

install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2022-03-02.
    # """
    local app pkgs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew 2>/dev/null || true)"
    )
    # Always install essential defaults.
    pkgs=(
        'pip'
        'setuptools'
        'wheel'
    )
    pkgs+=('pipx')
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
    readarray -t pkgs <<< "$(koopa_python_get_pkg_versions "${pkgs[@]}")"
    koopa_python_pip_install "${pkgs[@]}"
    return 0
}

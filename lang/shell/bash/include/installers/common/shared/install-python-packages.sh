#!/usr/bin/env bash

# NOTE Consider splitting out useful packages into virtualenvs instead.

main() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2022-04-06.
    # """
    local app dict pkgs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew --allow-missing)"
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    koopa_configure_python "${app[python]}"
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
    koopa_python_pip_install --prefix="${dict[prefix]}" "${pkgs[@]}"
    return 0
}

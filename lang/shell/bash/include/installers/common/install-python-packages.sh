#!/usr/bin/env bash

install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2022-03-30.
    # """
    local dict pkgs
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    pkgs=(
        'pip'
        'setuptools'
        'wheel'
    )
    # FIXME Split these out into venvs instead...
    # > pkgs+=('pipx')
    # > if [[ ! -x "${app[brew]}" ]]
    # > then
    # >     pkgs+=(
    # >         'black'
    # >         'bpytop'
    # >         'flake8'
    # >         'glances'
    # >         'pyflakes'
    # >         'pylint'
    # >         'pytest'
    # >         'ranger-fm'
    # >     )
    # > fi
    readarray -t pkgs <<< "$(koopa_python_get_pkg_versions "${pkgs[@]}")"
    koopa_python_pip_install --prefix="${dict[prefix]}" "${pkgs[@]}"
    return 0
}

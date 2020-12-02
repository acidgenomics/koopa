#!/usr/bin/env bash

koopa::install() { # {{{1
    # """
    # Install commands.
    # @note Updated 2020-12-02.
    # """
    local name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop 'Program name to install is required.'
    fi
    shift 1
    koopa::_run_function "install_${name}" "$@"
    return 0
}

koopa::install_py_koopa() { # {{{1
    # """
    # Install Python koopa package.
    # @note Updated 2020-11-23.
    # """
    local url
    koopa::python_add_site_packages_to_sys_path
    url='https://github.com/acidgenomics/koopa/archive/python.tar.gz'
    koopa::pip_install "$url"
    return 0
}

koopa::install_r_koopa() { # {{{1
    # """
    # Install koopa R package.
    # @note Updated 2020-11-23.
    # """
    koopa::rscript 'install-r-koopa'
    return 0
}

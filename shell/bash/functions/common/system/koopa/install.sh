#!/usr/bin/env bash

koopa::install_py_koopa() { # {{{1
    # """
    # Install Python koopa package.
    # @note Updated 2020-08-12.
    # """
    local url
    url='https://github.com/acidgenomics/koopa/archive/python.tar.gz'
    koopa::pip_install "$@" "$url"
    return 0
}

koopa::install_r_koopa() { # {{{1
    # """
    # Install koopa R package.
    # @note Updated 2020-08-12.
    # """
    local script
    koopa::assert_has_no_args "$#"
    koopa::is_installed Rscript || return 0
    script="$(koopa::prefix)/lang/r/include/install.R"
    koopa::assert_is_file "$script"
    Rscript "$script"
    return 0
}

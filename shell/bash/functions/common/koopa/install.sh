#!/usr/bin/env bash

koopa::install() { # {{{1
    # """
    # Install commands.
    # @note Updated 2020-11-18.
    # """
    local f fun name
    name="${1:-}"
    if [[ -z "$name" ]]
    then
        koopa::stop 'Program name to install is required.'
    fi
    f="install_${name//-/_}"
    # FIXME MAKE THIS A FUNCTION.
    if koopa::is_macos && koopa::is_function "koopa::macos_${f}"
    then
        fun="koopa::macos_${f}"
    elif koopa::is_linux && koopa::is_function "koopa::linux_${f}"
    then
        fun="koopa::linux_${f}"
    else
        fun="koopa::${f}"
    fi
    if ! koopa::is_function "$fun"
    then
        koopa::stop "No install script available for '${*}'."
    fi
    shift 1
    "$fun" "$@"
    return 0
}

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
    # @note Updated 2020-11-17.
    # """
    local script
    koopa::assert_has_no_args "$#"
    koopa::is_installed Rscript || return 0
    script="$(koopa::rscript_prefix)/install.R"
    koopa::assert_is_file "$script"
    Rscript "$script"
    return 0
}

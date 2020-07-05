#!/bin/sh

koopa::exit_if_current_version() { # {{{1
    # """
    # Assert that programs are installed and current.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_current_version "$arg"
        then
            koopa::exit "'${arg}' is current version."
        fi
    done
    return 0
}

koopa::exit_if_dir() { # {{{1
    # """
    # Exit with note if directory exists.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [ -d "$arg" ]
        then
            koopa::exit "Directory exists: '${arg}'."
        fi
    done
    return 0
}

koopa::exit_if_docker() { # {{{1
    # """
    # Exit with note if running inside Docker.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_docker
    then
        koopa::exit "Not supported when running inside Docker."
    fi
    return 0
}

koopa::exit_if_exists() { # {{{1
    # """
    # Exit with note if any file type exists.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if [ -e "$arg" ]
        then
            koopa::exit "Exists: '${arg}'."
        fi
    done
    return 0
}

koopa::exit_if_installed() { # {{{1
    # """
    # Exit with note if an app is installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_installed "$arg"
        then
            local where
            where="$(koopa::which_realpath "$arg")"
            koopa::exit "'${arg}' is installed at '${where}'."
        fi
    done
    return 0
}

koopa::exit_if_not_installed() { # {{{1
    # """
    # Exit with note if an app is not installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_installed "$arg"
        then
            koopa::exit "'${arg}' is not installed."
        fi
    done
    return 0
}

koopa::exit_if_python_package_not_installed() { # {{{1
    # """
    # Exit with note if a Python package is not installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_python_package_installed "$arg"
        then
            koopa::exit "'${arg}' Python package is not installed."
        fi
    done
    return 0
}

koopa::exit_if_r_package_installed() { # {{{1
    # """
    # Exit with note if a R package is installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if koopa::is_r_package_installed "$arg"
        then
            koopa::exit "'${arg}' R package is installed."
        fi
    done
    return 0
}

koopa::exit_if_r_package_not_installed() { # {{{1
    # """
    # Exit with note if a R package is not installed.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args "$#"
    for arg in "$@"
    do
        if ! koopa::is_r_package_installed "$arg"
        then
            koopa::exit "'${arg}' R package is not installed."
        fi
    done
    return 0
}

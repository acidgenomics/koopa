#!/bin/sh
# shellcheck disable=SC2039

_koopa_exit_if_current_version() { # {{{1
    # """
    # Assert that programs are installed and current.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if _koopa_is_current_version "$arg"
        then
            _koopa_exit "'${arg}' is current version."
        fi
    done
    return 0
}

_koopa_exit_if_dir() { # {{{1
    # """
    # Exit with note if directory exists.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ -d "$arg" ]
        then
            _koopa_exit "Directory exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_exit_if_docker() { # {{{1
    # """
    # Exit with note if running inside Docker.
    # @note Updated 2020-04-21.
    # """
    if _koopa_is_docker
    then
        _koopa_exit "Not supported when running inside Docker."
    fi
    return 0
}

_koopa_exit_if_exists() { # {{{1
    # """
    # Exit with note if any file type exists.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if [ -e "$arg" ]
        then
            _koopa_exit "Exists: '${arg}'."
        fi
    done
    return 0
}

_koopa_exit_if_installed() { # {{{1
    # """
    # Exit with note if an app is installed.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if _koopa_is_installed "$arg"
        then
            local where
            where="$(_koopa_which_realpath "$arg")"
            _koopa_exit "'${arg}' is installed at '${where}'."
        fi
    done
    return 0
}

_koopa_exit_if_not_installed() { # {{{1
    # """
    # Exit with note if an app is not installed.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_exit "'${arg}' is not installed."
        fi
    done
    return 0
}

_koopa_exit_if_python_package_not_installed() { # {{{1
    # """
    # Exit with note if a Python package is not installed.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_python_package_installed "$arg"
        then
            _koopa_exit "'${arg}' Python package is not installed."
        fi
    done
    return 0
}

_koopa_exit_if_r_package_installed() { # {{{1
    # """
    # Exit with note if a R package is installed.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if _koopa_is_r_package_installed "$arg"
        then
            _koopa_exit "'${arg}' R package is installed."
        fi
    done
    return 0
}

_koopa_exit_if_r_package_not_installed() { # {{{1
    # """
    # Exit with note if a R package is not installed.
    # @note Updated 2020-04-21.
    # """
    [ "$#" -ne 0 ] || return 1
    for arg
    do
        if ! _koopa_is_r_package_installed "$arg"
        then
            _koopa_exit "'${arg}' R package is not installed."
        fi
    done
    return 0
}

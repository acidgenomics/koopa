#!/usr/bin/env bash

koopa::install_start() { # {{{1
    # """
    # Inform the user about start of installation.
    # @note Updated 2020-07-07.
    # """
    local msg name version prefix
    koopa::assert_has_args_le "$#" 3
    name="${1:?}"
    version=''
    prefix=''
    if [[ "$#" -eq 2 ]]
    then
        prefix="${2:?}"
    elif [[ "$#" -eq 3 ]]
    then
        version="${2:?}"
        prefix="${3:?}"
    fi
    if [[ -n "$prefix" ]] && [[ -n "$version" ]]
    then
        msg="Installing ${name} ${version} at '${prefix}'."
    elif [[ -n "$prefix" ]]
    then
        msg="Installing ${name} at '${prefix}'."
    else
        msg="Installing ${name}."
    fi
    koopa::h1 "$msg"
    return 0
}

koopa::install_success() { # {{{1
    # """
    # Installation success message.
    # @note Updated 2020-11-17.
    # """
    local msg name prefix
    koopa::assert_has_args_le "$#" 2
    name="${1:?}"
    prefix="${2:-}"
    if [[ -n "$prefix" ]]
    then
        msg="Installation of ${name} at '${prefix}' was successful."
    else
        msg="Installation of ${name} was successful."
    fi
    koopa::alert_success "$msg"
    return 0
}

koopa::uninstall_start() { # {{{1
    # """
    # Inform the user about start of uninstall.
    # @note Updated 2020-03-05.
    # """
    local msg name prefix
    koopa::assert_has_args_le "$#" 2
    name="${1:?}"
    prefix="${2:-}"
    if [[ -n "$prefix" ]]
    then
        msg="Uninstalling ${name} at '${prefix}'."
    else
        msg="Uninstalling ${name}."
    fi
    koopa::h1 "$msg"
    return 0
}

koopa::uninstall_success() { # {{{1
    # """
    # Uninstall success message.
    # @note Updated 2020-11-17.
    # """
    local msg name prefix
    koopa::assert_has_args_le "$#" 2
    name="${1:?}"
    prefix="${2:-}"
    if [[ -n "$prefix" ]]
    then
        msg="Uninstallation of ${name} at '${prefix}' was successful."
    else
        msg="Uninstallation of ${name} was successful."
    fi
    koopa::alert_success "$msg"
    return 0
}

koopa::update_start() { # {{{1
    # """
    # Inform the user about start of update.
    # @note Updated 2020-07-01.
    # """
    local name msg prefix
    koopa::assert_has_args "$#"
    name="${1:?}"
    prefix="${2:-}"
    if [[ -n "$prefix" ]]
    then
        msg="Updating ${name} at '${prefix}'."
    else
        msg="Updating ${name}."
    fi
    koopa::h1 "$msg"
    return 0
}

koopa::update_success() { # {{{1
    # """
    # Update success message.
    # @note Updated 2020-11-17.
    # """
    local msg name prefix
    koopa::assert_has_args_le "$#" 2
    name="${1:?}"
    prefix="${2:-}"
    if [[ -n "$prefix" ]]
    then
        msg="Update of ${name} at '${prefix}' was successful."
    else
        msg="Update of ${name} was successful."
    fi
    koopa::alert_success "$msg"
    return 0
}

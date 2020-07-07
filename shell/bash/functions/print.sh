#!/usr/bin/env bash

koopa::_status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2020-07-07.
    # """
    local color nocolor label string x
    koopa::assert_has_args_ge "$#" 3
    label="$(printf '%10s\n' "${1:?}")"
    color="$(koopa::_ansi_escape "${2:?}")"
    nocolor="$(koopa::_ansi_escape 'nocolor')"
    shift 2
    for string in "$@"
    do
        x="${color}${label}${nocolor} | ${string}"
        koopa::print "$x"
    done
    return 0
}

koopa::coffee_time() { # {{{1
    # """
    # Coffee time.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::note 'This step takes a while. Time for a coffee break! ☕☕'
    return 0
}

koopa::exit() { # {{{1
    # """
    # Exit showing note, without error.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::note "${1:?}"
    exit 0
}

koopa::install_start() { # {{{1
    # """
    # Inform the user about start of installation.
    # @note Updated 2020-07-07.
    # """
    local msg name version prefix
    koopa::assert_has_args_le "$#" 3
    name="${1:?}"
    version=
    prefix=
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
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::success "Installation of ${1:?} was successful."
    return 0
}

koopa::restart() { # {{{1
    # """
    # Inform the user that they should restart shell.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::note 'Restart the shell.'
    return 0
}

koopa::status_fail() { # {{{1
    # """
    # FAIL status.
    # @note Updated 2020-07-07.
    # """
    koopa::assert_has_args "$#"
    koopa::_status 'FAIL' 'red' "$@" >&2
    return 0
}

koopa::status_note() { # {{{1
    # """
    # NOTE status.
    # @note Updated 2020-07-07.
    # """
    koopa::assert_has_args "$#"
    koopa::_status 'NOTE' 'yellow' "$@"
    return 0
}

koopa::status_ok() { # {{{1
    # """
    # OK status.
    # @note Updated 2020-07-07.
    # """
    koopa::assert_has_args "$#"
    koopa::_status 'OK' 'green' "$@"
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
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::success "Uninstallation of ${1:?} was successful."
    return 0
}

koopa::update_start() { # {{{1
    # """
    # Inform the user about start of update.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    local name msg prefix
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
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::success "Update of ${1:?} was successful."
    return 0
}


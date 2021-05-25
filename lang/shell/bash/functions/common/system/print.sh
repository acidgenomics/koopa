#!/usr/bin/env bash

koopa:::alert_process_start() { # {{{1
    # """
    # Inform the user about the start of a process.
    # @note Updated 2021-05-25.
    # """
    local msg name version prefix word
    word="${1:?}"
    shift 1
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
        msg="${word} ${name} ${version} at '${prefix}'."
    elif [[ -n "$prefix" ]]
    then
        msg="${word} ${name} at '${prefix}'."
    else
        msg="${word} ${name}."
    fi
    koopa::h1 "$msg"
    return 0
}

koopa:::alert_process_success() { # {{{1
    # """
    # Inform the user about the successful completion of a process.
    # @note Updated 2021-05-25.
    # """
    local msg name prefix word
    word="${1:?}"
    shift 1
    koopa::assert_has_args_le "$#" 2
    name="${1:?}"
    prefix="${2:-}"
    if [[ -n "$prefix" ]]
    then
        msg="${word} of ${name} at '${prefix}' was successful."
    else
        msg="${word} of ${name} was successful."
    fi
    koopa::alert_success "$msg"
    return 0
}

koopa::configure_start() { # {{{1
    koopa:::alert_process_start 'Configuring' "$@"
}

koopa::configure_success() { # {{{1
    koopa:::alert_process_success 'Configuration' "$@"
}

koopa::install_start() { # {{{1
    koopa:::alert_process_start 'Installing' "$@"
}

koopa::install_success() { # {{{1
    koopa:::alert_process_success 'Installation' "$@"
}

koopa::uninstall_start() { # {{{1
    koopa:::alert_process_start 'Uninstalling' "$@"
}

koopa::uninstall_success() { # {{{1
    koopa:::alert_process_success 'Uninstallation' "$@"
}

koopa::update_start() { # {{{1
    koopa:::alert_process_start 'Updating' "$@"
}

koopa::update_success() { # {{{1
    koopa:::alert_process_success 'Update' "$@"
}

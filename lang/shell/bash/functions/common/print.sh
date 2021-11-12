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

koopa:::status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2021-06-03.
    # """
    local color nocolor label string x
    koopa::assert_has_args_ge "$#" 3
    label="$(printf '%10s\n' "${1:?}")"
    color="$(koopa:::ansi_escape "${2:?}")"
    nocolor="$(koopa:::ansi_escape 'nocolor')"
    shift 2
    for string in "$@"
    do
        x="${color}${label}${nocolor} | ${string}"
        koopa::print "$x"
    done
    return 0
}

koopa::alert_coffee_time() { # {{{1
    # """
    # Alert that it's coffee time.
    # @note Updated 2021-03-31.
    # """
    koopa::alert_note 'This step takes a while. Time for a coffee break! ☕'
    return 0
}

koopa::alert_restart() { # {{{1
    # """
    # Alert the user that they should restart shell.
    # @note Updated 2021-06-02.
    # """
    koopa::alert_note 'Restart the shell.'
    return 0
}

# FIXME Consider prefixing this with "alert".
koopa::configure_start() { # {{{1
    koopa:::alert_process_start 'Configuring' "$@"
}

# FIXME Consider prefixing this with "alert".
koopa::configure_success() { # {{{1
    koopa:::alert_process_success 'Configuration' "$@"
}

# FIXME Consider prefixing this with "alert".
koopa::install_start() { # {{{1
    koopa:::alert_process_start 'Installing' "$@"
}

# FIXME Consider prefixing this with "alert".
koopa::install_success() { # {{{1
    koopa:::alert_process_success 'Installation' "$@"
}

koopa::invalid_arg() { # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2021-09-21.
    # """
    local arg x
    if [[ "$#" -gt 0 ]]
    then
        arg="${1:-}"
        # > if koopa::str_match_posix "$arg" '--'
        # > then
        # >     koopa::warn "Use '--arg=VALUE' not '--arg VALUE'."
        # > fi
        x="Invalid argument: '${arg}'."
    else
        x='Invalid argument.'
    fi
    koopa::stop "$x"
}

koopa::missing_arg() { # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2021-06-02.
    # """
    koopa::stop 'Missing required argument.'
}

koopa::status_fail() { # {{{1
    # """
    # 'FAIL' status.
    # @note Updated 2021-06-03.
    # """
    koopa:::status 'FAIL' 'red' "$@" >&2
    return 0
}

koopa::status_note() { # {{{1
    # """
    # 'NOTE' status.
    # @note Updated 2021-06-03.
    # """
    koopa:::status 'NOTE' 'yellow' "$@"
    return 0
}

koopa::status_ok() { # {{{1
    # """
    # 'OK' status.
    # @note Updated 2021-06-03.
    # """
    koopa:::status 'OK' 'green' "$@"
    return 0
}

koopa::stop() { # {{{1
    # """
    # Stop with an error message, and exit.
    # @note Updated 2021-06-03.
    #
    # Defining here rather than in POSIX functions library, since we never want
    # to use 'exit' inside of activation scripts. This can cause unwanted shell
    # lockout.
    # """
    koopa:::msg 'red-bold' 'red' '!! Error:' "$@" >&2
    exit 1
}

# FIXME Consider prefixing this with "alert".
koopa::uninstall_start() { # {{{1
    koopa:::alert_process_start 'Uninstalling' "$@"
}

# FIXME Consider prefixing this with "alert".
koopa::uninstall_success() { # {{{1
    koopa:::alert_process_success 'Uninstallation' "$@"
}

# FIXME Consider prefixing this with "alert".
koopa::update_start() { # {{{1
    koopa:::alert_process_start 'Updating' "$@"
}

# FIXME Consider prefixing this with "alert".
koopa::update_success() { # {{{1
    koopa:::alert_process_success 'Update' "$@"
}

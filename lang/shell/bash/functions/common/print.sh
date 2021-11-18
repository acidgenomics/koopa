#!/usr/bin/env bash

koopa:::alert_process_start() { # {{{1
    # """
    # Inform the user about the start of a process.
    # @note Updated 2021-11-18.
    # """
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa::assert_has_args_le "$#" 3
    dict[name]="${1:?}"
    dict[version]=''
    dict[prefix]=''
    if [[ "$#" -eq 2 ]]
    then
        dict[prefix]="${2:?}"
    elif [[ "$#" -eq 3 ]]
    then
        dict[version]="${2:?}"
        dict[prefix]="${3:?}"
    fi
    if [[ -n "${dict[prefix]}" ]] && [[ -n "${dict[version]}" ]]
    then
        out="${dict[word]} ${dict[name]} ${dict[version]} at '${dict[prefix]}'."
    elif [[ -n "${dict[prefix]}" ]]
    then
        out="${dict[word]} ${dict[name]} at '${dict[prefix]}'."
    else
        out="${dict[word]} ${dict[name]}."
    fi
    koopa::h1 "${dict[out]}"
    return 0
}

koopa:::alert_process_success() { # {{{1
    # """
    # Inform the user about the successful completion of a process.
    # @note Updated 2021-11-18.
    # """
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa::assert_has_args_le "$#" 2
    dict[name]="${1:?}"
    dict[prefix]="${2:-}"
    if [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} of ${dict[name]} at '${dict[prefix]}' \
was successful."
    else
        dict[out]="${dict[word]} of ${dict[name]} was successful."
    fi
    koopa::alert_success "${dict[out]}"
    return 0
}

koopa:::status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2021-11-18.
    # """
    local dict string
    koopa::assert_has_args_ge "$#" 3
    declare -A dict=(
        [label]="$(printf '%10s\n' "${1:?}")"
        [color]="$(koopa:::ansi_escape "${2:?}")"
        [nocolor]="$(koopa:::ansi_escape 'nocolor')"
    )
    shift 2
    for string in "$@"
    do
        string="${dict[color]}${dict[label]}${dict[nocolor]} | ${string}"
        koopa::print "$string"
    done
    return 0
}

koopa::alert_coffee_time() { # {{{1
    # """
    # Alert that it's coffee time.
    # @note Updated 2021-03-31.
    # """
    koopa::alert_note 'This step takes a while. Time for a coffee break! ☕'
}

koopa::alert_configure_start() { # {{{1
    koopa:::alert_process_start 'Configuring' "$@"
}

koopa::alert_configure_success() { # {{{1
    koopa:::alert_process_success 'Configuration' "$@"
}

koopa::alert_install_start() { # {{{1
    koopa:::alert_process_start 'Installing' "$@"
}

koopa::alert_install_success() { # {{{1
    koopa:::alert_process_success 'Installation' "$@"
}

koopa::alert_restart() { # {{{1
    # """
    # Alert the user that they should restart shell.
    # @note Updated 2021-06-02.
    # """
    koopa::alert_note 'Restart the shell.'
}

koopa::alert_uninstall_start() { # {{{1
    koopa:::alert_process_start 'Uninstalling' "$@"
}

koopa::alert_uninstall_success() { # {{{1
    koopa:::alert_process_success 'Uninstallation' "$@"
}

koopa::alert_update_start() { # {{{1
    koopa:::alert_process_start 'Updating' "$@"
}

koopa::alert_update_success() { # {{{1
    koopa:::alert_process_success 'Update' "$@"
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
}

koopa::status_note() { # {{{1
    # """
    # 'NOTE' status.
    # @note Updated 2021-06-03.
    # """
    koopa:::status 'NOTE' 'yellow' "$@"
}

koopa::status_ok() { # {{{1
    # """
    # 'OK' status.
    # @note Updated 2021-06-03.
    # """
    koopa:::status 'OK' 'green' "$@"
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

#!/usr/bin/env bash

koopa:::h() { # {{{1
    # """
    # Header message generator.
    # @note Updated 2022-01-20.
    # """
    local dict
    koopa::assert_has_args_ge "$#" 2
    declare -A dict=(
        [emoji]="$(koopa::acid_emoji)"
        [level]="${1:?}"
    )
    shift 1
    case "${dict[level]}" in
        '1')
            koopa::print ''
            dict[prefix]='#'
            ;;
        '2')
            dict[prefix]='##'
            ;;
        '3')
            dict[prefix]='###'
            ;;
        '4')
            dict[prefix]='####'
            ;;
        '5')
            dict[prefix]='#####'
            ;;
        '6')
            dict[prefix]='######'
            ;;
        '7')
            dict[prefix]='#######'
            ;;
        *)
            koopa::stop 'Invalid header level.'
            ;;
    esac
    koopa:::msg 'magenta' 'default' "${dict[emoji]} ${dict[prefix]}" "$@"
    return 0
}

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
        dict[out]="${dict[word]} ${dict[name]} ${dict[version]} \
at '${dict[prefix]}'."
    elif [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} ${dict[name]} at '${dict[prefix]}'."
    else
        dict[out]="${dict[word]} ${dict[name]}."
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

koopa::acid_emoji() { # {{{1
    # """
    # Acid Genomics test tube emoji.
    # @note Updated 2022-01-20.
    #
    # Previous versions defaulted to using the '🐢' turtle.
    # """
    koopa::assert_has_no_args "$#"
    koopa::print '🧪'
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

koopa::h1() { # {{{1
    # """
    # Header level 1.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 1 "$@"
}

koopa::h2() { # {{{1
    # """
    # Header level 2.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 2 "$@"
}

koopa::h3() { # {{{1
    # """
    # Header level 3.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 3 "$@"
}

koopa::h4() { # {{{1
    # """
    # Header level 4.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 4 "$@"
}

koopa::h5() { # {{{1
    # """
    # Header level 5.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 5 "$@"
}

koopa::h6() { # {{{1
    # """
    # Header level 6.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 6 "$@"
}

koopa::h7() { # {{{1
    # """
    # Header level 7.
    # @note Updated 2022-01-20.
    # """
    koopa:::h 7 "$@"
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
        # > if koopa::str_detect_posix "$arg" '--'
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

# FIXME Improve our handling here, always returning with the input number.
# FIXME This will make handling in CLI alert calls easier.

koopa::ngettext() { # {{{1
    # """
    # Translate a text message.
    # @note Updated 2022-01-20.
    #
    # A function to dynamically handle singular/plural words.
    #
    # @examples
    # koopa::ngettext 1 'sample' 'samples'
    # ## sample
    # koopa::ngettext 2 'sample' 'samples'
    # ## samples
    #
    # @seealso
    # - https://stat.ethz.ch/R-manual/R-devel/library/base/html/gettext.html
    # - https://www.php.net/manual/en/function.ngettext.php
    # - https://www.oreilly.com/library/view/bash-cookbook/
    #       0596526784/ch13s08.html
    # """
    local dict
    koopa::assert_has_args_eq "$#" 3
    declare -A dict=(
        [n]="${1:?}"
        [msg1]="${2:?}"
        [msg2]="${3:?}"
    )
    if [[ "${dict[n]}" -eq 1 ]]
    then
        dict[str]="${dict[msg1]}"
    else
        dict[str]="${dict[msg2]}"
    fi
    koopa::print "${dict[str]}"
    return 0
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

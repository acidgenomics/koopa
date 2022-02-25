#!/usr/bin/env bash

__koopa_h() { # {{{1
    # """
    # Header message generator.
    # @note Updated 2022-01-20.
    # """
    local dict
    koopa_assert_has_args_ge "$#" 2
    declare -A dict=(
        [emoji]="$(koopa_acid_emoji)"
        [level]="${1:?}"
    )
    shift 1
    case "${dict[level]}" in
        '1')
            koopa_print ''
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
            koopa_stop 'Invalid header level.'
            ;;
    esac
    __koopa_msg 'magenta' 'default' "${dict[emoji]} ${dict[prefix]}" "$@"
    return 0
}

__koopa_alert_process_start() { # {{{1
    # """
    # Inform the user about the start of a process.
    # @note Updated 2021-11-18.
    # """
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 3
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
    koopa_h1 "${dict[out]}"
    return 0
}

__koopa_alert_process_success() { # {{{1
    # """
    # Inform the user about the successful completion of a process.
    # @note Updated 2021-11-18.
    # """
    local dict
    declare -A dict
    dict[word]="${1:?}"
    shift 1
    koopa_assert_has_args_le "$#" 2
    dict[name]="${1:?}"
    dict[prefix]="${2:-}"
    if [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} of ${dict[name]} at '${dict[prefix]}' \
was successful."
    else
        dict[out]="${dict[word]} of ${dict[name]} was successful."
    fi
    koopa_alert_success "${dict[out]}"
    return 0
}

__koopa_status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2021-11-18.
    # """
    local dict string
    koopa_assert_has_args_ge "$#" 3
    declare -A dict=(
        [label]="$(printf '%10s\n' "${1:?}")"
        [color]="$(__koopa_ansi_escape "${2:?}")"
        [nocolor]="$(__koopa_ansi_escape 'nocolor')"
    )
    shift 2
    for string in "$@"
    do
        string="${dict[color]}${dict[label]}${dict[nocolor]} | ${string}"
        koopa_print "$string"
    done
    return 0
}

koopa_acid_emoji() { # {{{1
    # """
    # Acid Genomics test tube emoji.
    # @note Updated 2022-01-20.
    #
    # Previous versions defaulted to using the '🐢' turtle.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '🧪'
}

koopa_alert_coffee_time() { # {{{1
    # """
    # Alert that it's coffee time.
    # @note Updated 2021-03-31.
    # """
    koopa_alert_note 'This step takes a while. Time for a coffee break! ☕'
}

koopa_alert_configure_start() { # {{{1
    __koopa_alert_process_start 'Configuring' "$@"
}

koopa_alert_configure_success() { # {{{1
    __koopa_alert_process_success 'Configuration' "$@"
}

koopa_alert_install_start() { # {{{1
    __koopa_alert_process_start 'Installing' "$@"
}

koopa_alert_install_success() { # {{{1
    __koopa_alert_process_success 'Installation' "$@"
}

koopa_alert_restart() { # {{{1
    # """
    # Alert the user that they should restart shell.
    # @note Updated 2021-06-02.
    # """
    koopa_alert_note 'Restart the shell.'
}

koopa_alert_uninstall_start() { # {{{1
    __koopa_alert_process_start 'Uninstalling' "$@"
}

koopa_alert_uninstall_success() { # {{{1
    __koopa_alert_process_success 'Uninstallation' "$@"
}

koopa_alert_update_start() { # {{{1
    __koopa_alert_process_start 'Updating' "$@"
}

koopa_alert_update_success() { # {{{1
    __koopa_alert_process_success 'Update' "$@"
}

koopa_h1() { # {{{1
    # """
    # Header level 1.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 1 "$@"
}

koopa_h2() { # {{{1
    # """
    # Header level 2.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 2 "$@"
}

koopa_h3() { # {{{1
    # """
    # Header level 3.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 3 "$@"
}

koopa_h4() { # {{{1
    # """
    # Header level 4.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 4 "$@"
}

koopa_h5() { # {{{1
    # """
    # Header level 5.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 5 "$@"
}

koopa_h6() { # {{{1
    # """
    # Header level 6.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 6 "$@"
}

koopa_h7() { # {{{1
    # """
    # Header level 7.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 7 "$@"
}

koopa_invalid_arg() { # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2022-02-17.
    # """
    local arg str
    if [[ "$#" -gt 0 ]]
    then
        arg="${1:-}"
        str="Invalid argument: '${arg}'."
    else
        str='Invalid argument.'
    fi
    koopa_stop "$str"
}

koopa_missing_arg() { # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2021-06-02.
    # """
    koopa_stop 'Missing required argument.'
}

koopa_ngettext() { # {{{1
    # """
    # Translate a text message.
    # @note Updated 2022-02-16.
    #
    # A function to dynamically handle singular/plural words.
    #
    # @examples
    # koopa_ngettext --num=1 --msg1='sample' --msg2='samples'
    # ## 1 sample
    # koopa_ngettext --num=2 --msg1='sample' --msg2='samples'
    # ## 2 samples
    #
    # @seealso
    # - https://stat.ethz.ch/R-manual/R-devel/library/base/html/gettext.html
    # - https://www.php.net/manual/en/function.ngettext.php
    # - https://www.oreilly.com/library/view/bash-cookbook/
    #       0596526784/ch13s08.html
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [middle]=' '
        [msg1]=''
        [msg2]=''
        [num]=''
        [prefix]=''
        [str]=''
        [suffix]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--middle='*)
                dict[middle]="${1#*=}"
                shift 1
                ;;
            '--middle')
                dict[middle]="${2:?}"
                shift 2
                ;;
            '--msg1='*)
                dict[msg1]="${1#*=}"
                shift 1
                ;;
            '--msg1')
                dict[msg1]="${2:?}"
                shift 2
                ;;
            '--msg2='*)
                dict[msg2]="${1#*=}"
                shift 1
                ;;
            '--msg2')
                dict[msg2]="${2:?}"
                shift 2
                ;;
            '--num='*)
                dict[num]="${1#*=}"
                shift 1
                ;;
            '--num')
                dict[num]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--suffix='*)
                dict[suffix]="${1#*=}"
                shift 1
                ;;
            '--suffix')
                dict[suffix]="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--middle' "${dict[middle]}"  \
        '--msg1' "${dict[msg1]}"  \
        '--msg2' "${dict[msg2]}"  \
        '--num' "${dict[num]}"
    # Pad the prefix and suffix automatically, if desired.
    # > [[ -n "${dict[prefix]}" ]] && dict[prefix]="${dict[prefix]} "
    # > [[ -n "${dict[suffix]}" ]] && dict[suffix]=" ${dict[suffix]}"
    case "${dict[num]}" in
        '1')
            dict[msg]="${dict[msg1]}"
            ;;
        *)
            dict[msg]="${dict[msg2]}"
            ;;
    esac
    dict[str]="${dict[prefix]}${dict[num]}${dict[middle]}\
${dict[msg]}${dict[suffix]}"
    koopa_print "${dict[str]}"
    return 0
}

koopa_status_fail() { # {{{1
    # """
    # 'FAIL' status.
    # @note Updated 2021-06-03.
    # """
    __koopa_status 'FAIL' 'red' "$@" >&2
}

koopa_status_note() { # {{{1
    # """
    # 'NOTE' status.
    # @note Updated 2021-06-03.
    # """
    __koopa_status 'NOTE' 'yellow' "$@"
}

koopa_status_ok() { # {{{1
    # """
    # 'OK' status.
    # @note Updated 2021-06-03.
    # """
    __koopa_status 'OK' 'green' "$@"
}

koopa_stop() { # {{{1
    # """
    # Stop with an error message, and kill the parent process.
    # @note Updated 2022-02-16.
    #
    # NOTE Using 'exit' here doesn't not reliably stop inside command substition
    # and subshells, even with errexit and errtrace enabled.
    #
    # Defining here rather than in POSIX functions library, since we never want
    # to stop inside of activation scripts. This can cause unwanted lockout.
    #
    # @seealso
    # - https://unix.stackexchange.com/questions/256873/
    # - https://stackoverflow.com/questions/28657676/
    # - https://linuxize.com/post/kill-command-in-linux/
    # - https://unix.stackexchange.com/questions/478281/
    # - https://stackoverflow.com/questions/41370092/
    # """
    unset kill
    __koopa_msg 'red-bold' 'red' '!! Error:' "$@" >&2
    [[ -n "${!:-}" ]] && kill -SIGKILL "${!}"  # subprocess
    [[ -n "${$:-}" ]] && kill -SIGKILL "${$}"  # parent
    exit 1
}

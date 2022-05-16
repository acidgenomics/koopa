#!/usr/bin/env bash

koopa_alert_coffee_time() {
    koopa_alert_note 'This step takes a while. Time for a coffee break! ☕'
}

koopa_alert_configure_start() {
    __koopa_alert_process_start 'Configuring' "$@"
}

koopa_alert_configure_success() {
    __koopa_alert_process_success 'Configuration' "$@"
}

koopa_alert_info() {
    # """
    # Alert info message.
    # @note Updated 2021-03-30.
    # """
    __koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

koopa_alert_install_start() {
    __koopa_alert_process_start 'Installing' "$@"
}

koopa_alert_install_success() {
    __koopa_alert_process_success 'Installation' "$@"
}

koopa_alert_is_installed() {
    # """
    # Alert the user that a program is installed.
    # @note Updated 2022-04-11.
    # """
    local name prefix
    name="${1:?}"
    prefix="${2:-}"
    x="${name} is installed"
    if [[ -n "$prefix" ]]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    koopa_alert_note "$x"
    return 0
}

koopa_alert_is_not_installed() {
    # """
    # Alert the user that a program is not installed.
    # @note Updated 2022-04-08.
    # """
    local name prefix
    name="${1:?}"
    prefix="${2:-}"
    x="'${name}' not installed"
    if [[ -n "$prefix" ]]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    koopa_alert_note "$x"
    return 0
}

koopa_alert_note() {
    # """
    # General note.
    # @note Updated 2020-07-01.
    # """
    __koopa_msg 'yellow' 'default' '**' "$@"
}

koopa_alert_restart() {
    # """
    # Alert the user that they should restart shell.
    # @note Updated 2021-06-02.
    # """
    koopa_alert_note 'Restart the shell.'
}

koopa_alert_success() {
    # """
    # Alert success message.
    # @note Updated 2021-03-31.
    # """
    __koopa_msg 'green-bold' 'green' '✓' "$@"
}

koopa_alert_uninstall_start() {
    __koopa_alert_process_start 'Uninstalling' "$@"
}

koopa_alert_uninstall_success() {
    __koopa_alert_process_success 'Uninstallation' "$@"
}

koopa_alert_update_start() {
    __koopa_alert_process_start 'Updating' "$@"
}

koopa_alert_update_success() {
    __koopa_alert_process_success 'Update' "$@"
}

koopa_dl() {
    # """
    # Definition list.
    # @note Updated 2022-04-01.
    # """
    koopa_assert_has_args_ge "$#" 2
    while [[ "$#" -ge 2 ]]
    do
        __koopa_msg 'default-bold' 'default' "${1:?}:" "${2:-}"
        shift 2
    done
    return 0
}

koopa_h1() {
    # """
    # Header level 1.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 1 "$@"
}

koopa_h2() {
    # """
    # Header level 2.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 2 "$@"
}

koopa_h3() {
    # """
    # Header level 3.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 3 "$@"
}

koopa_h4() {
    # """
    # Header level 4.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 4 "$@"
}

koopa_h5() {
    # """
    # Header level 5.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 5 "$@"
}

koopa_h6() {
    # """
    # Header level 6.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 6 "$@"
}

koopa_h7() {
    # """
    # Header level 7.
    # @note Updated 2022-01-20.
    # """
    __koopa_h 7 "$@"
}

koopa_invalid_arg() {
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

koopa_missing_arg() {
    # """
    # Error on a missing argument.
    # @note Updated 2021-06-02.
    # """
    koopa_stop 'Missing required argument.'
}

koopa_ngettext() {
    # """
    # Translate a text message.
    # @note Updated 2022-02-16.
    #
    # A function to dynamically handle singular/plural words.
    #
    # @examples
    # > koopa_ngettext --num=1 --msg1='sample' --msg2='samples'
    # # 1 sample
    # > koopa_ngettext --num=2 --msg1='sample' --msg2='samples'
    # # 2 samples
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

koopa_print_black() {
    __koopa_print_ansi 'black' "$@"
    return 0
}

koopa_print_black_bold() {
    __koopa_print_ansi 'black-bold' "$@"
    return 0
}

koopa_print_blue() {
    __koopa_print_ansi 'blue' "$@"
    return 0
}

koopa_print_blue_bold() {
    __koopa_print_ansi 'blue-bold' "$@"
    return 0
}

koopa_print_cyan() {
    __koopa_print_ansi 'cyan' "$@"
    return 0
}

koopa_print_cyan_bold() {
    __koopa_print_ansi 'cyan-bold' "$@"
    return 0
}

koopa_print_default() {
    __koopa_print_ansi 'default' "$@"
    return 0
}

koopa_print_default_bold() {
    __koopa_print_ansi 'default-bold' "$@"
    return 0
}

koopa_print_green() {
    __koopa_print_ansi 'green' "$@"
    return 0
}

koopa_print_green_bold() {
    __koopa_print_ansi 'green-bold' "$@"
    return 0
}

koopa_print_magenta() {
    __koopa_print_ansi 'magenta' "$@"
    return 0
}

koopa_print_magenta_bold() {
    __koopa_print_ansi 'magenta-bold' "$@"
    return 0
}

koopa_print_red() {
    __koopa_print_ansi 'red' "$@"
    return 0
}

koopa_print_red_bold() {
    __koopa_print_ansi 'red-bold' "$@"
    return 0
}

koopa_print_yellow() {
    __koopa_print_ansi 'yellow' "$@"
    return 0
}

koopa_print_yellow_bold() {
    __koopa_print_ansi 'yellow-bold' "$@"
    return 0
}

koopa_print_white() {
    __koopa_print_ansi 'white' "$@"
    return 0
}

koopa_print_white_bold() {
    __koopa_print_ansi 'white-bold' "$@"
    return 0
}

koopa_status_fail() {
    # """
    # 'FAIL' status.
    # @note Updated 2021-06-03.
    # """
    __koopa_status 'FAIL' 'red' "$@" >&2
}

koopa_status_note() {
    # """
    # 'NOTE' status.
    # @note Updated 2021-06-03.
    # """
    __koopa_status 'NOTE' 'yellow' "$@"
}

koopa_status_ok() {
    # """
    # 'OK' status.
    # @note Updated 2021-06-03.
    # """
    __koopa_status 'OK' 'green' "$@"
}

koopa_stop() {
    # """
    # Stop with an error message.
    # @note Updated 2022-04-11.
    # """
    __koopa_msg 'red-bold' 'red' '!! Error:' "$@" >&2
    exit 1
}

koopa_warn() {
    # """
    # Warning message.
    # @note Updated 2022-02-24.
    # """
    __koopa_msg 'magenta-bold' 'magenta' '!!' "$@" >&2
    return 0
}

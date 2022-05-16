#!/usr/bin/env bash

# NOTE Rework these to use r-cli style inline markup syntax:
# https://cli.r-lib.org/reference/inline-markup.html
#
# The default theme defines the following inline classes:
#
# - 'arg' for a function argument.
# - 'cls' for an S3, S4, R6 or other class name.
# - 'code' for a piece of code.
# - 'dd' is used for the descriptions in a definition list (cli_dl()).
# - 'dt' is used for the terms in a definition list (cli_dl()).
# - 'email' for an email address.
# - 'emph' for emphasized text.
# - 'envvar' for the name of an environment variable.
# - 'field' for a generic field, e.g. in a named list.
# - 'file' for a file name.
# - 'fun' for a function name.
# - 'key' for a keyboard key.
# - 'path' for a path (essentially the same as file).
# - 'pkg' for a package name.
# - 'strong' for strong importance.
# - 'url' for a URL.
# - 'val' for a generic "value".
# - 'var' for a variable name.

__koopa_alert_process_start() {
    # """
    # Inform the user about the start of a process.
    # @note Updated 2022-04-08.
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
        dict[out]="${dict[word]} '${dict[name]}' ${dict[version]} \
at '${dict[prefix]}'."
    elif [[ -n "${dict[prefix]}" ]]
    then
        dict[out]="${dict[word]} '${dict[name]}' at '${dict[prefix]}'."
    else
        dict[out]="${dict[word]} '${dict[name]}'."
    fi
    koopa_alert "${dict[out]}"
    return 0
}

__koopa_alert_process_success() {
    # """
    # Inform the user about the successful completion of a process.
    # @note Updated 2022-03-09.
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
        dict[out]="${dict[word]} of '${dict[name]}' at '${dict[prefix]}' \
was successful."
    else
        dict[out]="${dict[word]} of '${dict[name]}' was successful."
    fi
    koopa_alert_success "${dict[out]}"
    return 0
}

__koopa_status() {
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

__koopa_ansi_escape() {
    # """
    # ANSI escape codes.
    # @note Updated 2020-07-05.
    # """
    local escape
    case "${1:?}" in
        'nocolor')
            escape='0'
            ;;
        'default')
            escape='0;39'
            ;;
        'default-bold')
            escape='1;39'
            ;;
        'black')
            escape='0;30'
            ;;
        'black-bold')
            escape='1;30'
            ;;
        'blue')
            escape='0;34'
            ;;
        'blue-bold')
            escape='1;34'
            ;;
        'cyan')
            escape='0;36'
            ;;
        'cyan-bold')
            escape='1;36'
            ;;
        'green')
            escape='0;32'
            ;;
        'green-bold')
            escape='1;32'
            ;;
        'magenta')
            escape='0;35'
            ;;
        'magenta-bold')
            escape='1;35'
            ;;
        'red')
            escape='0;31'
            ;;
        'red-bold')
            escape='1;31'
            ;;
        'yellow')
            escape='0;33'
            ;;
        'yellow-bold')
            escape='1;33'
            ;;
        'white')
            escape='0;97'
            ;;
        'white-bold')
            escape='1;97'
            ;;
        *)
            return 1
            ;;
    esac
    printf '\033[%sm' "$escape"
    return 0
}

__koopa_h() {
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

__koopa_msg() {
    # """
    # Standard message generator.
    # @note Updated 2022-02-25.
    # """
    local c1 c2 nc prefix str
    c1="$(__koopa_ansi_escape "${1:?}")"
    c2="$(__koopa_ansi_escape "${2:?}")"
    nc="$(__koopa_ansi_escape 'nocolor')"
    prefix="${3:?}"
    shift 3
    for str in "$@"
    do
        koopa_print "${c1}${prefix}${nc} ${c2}${str}${nc}"
    done
    return 0
}

__koopa_print_ansi() {
    # """
    # Print a colored line in console.
    # @note Updated 2022-02-25.
    #
    # Currently using ANSI escape codes.
    # This is the classic 8 color terminal approach.
    #
    # - '0;': normal
    # - '1;': bright or bold
    #
    # (taken from Travis CI config)
    # - clear=\033[0K
    # - nocolor=\033[0m
    #
    # Alternative approach (non-POSIX):
    # echo command requires '-e' flag to allow backslash escapes.
    #
    # See also:
    # - https://en.wikipedia.org/wiki/ANSI_escape_code
    # - https://misc.flogisoft.com/bash/tip_colors_and_formatting
    # - https://stackoverflow.com/questions/5947742
    # - https://stackoverflow.com/questions/15736223
    # - https://bixense.com/clicolors/
    # """
    local color nocolor str
    color="$(__koopa_ansi_escape "${1:?}")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    shift 1
    for str in "$@"
    do
        printf '%s%b%s\n' "$color" "$str" "$nocolor"
    done
    return 0
}

koopa_acid_emoji() {
    # """
    # Acid Genomics test tube emoji.
    # @note Updated 2022-01-20.
    #
    # Previous versions defaulted to using the '🐢' turtle.
    # """
    koopa_print '🧪'
}

koopa_alert() {
    # """
    # Alert message.
    # @note Updated 2021-03-31.
    # """
    __koopa_msg 'default' 'default' '→' "$@"
    return 0
}

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

#!/bin/sh

__koopa_acid_emoji() { # {{{1
    # """
    # Acid Genomics test tube emoji.
    # @note Updated 2021-03-31.
    #
    # Previous versions defaulted to using the '🐢' turtle.
    # """
    _koopa_print '🧪'
}

__koopa_ansi_escape() { # {{{1
    # """
    # ANSI escape codes.
    # @note Updated 2020-07-05.
    # """
    local escape
    case "${1:?}" in
        nocolor)
            escape='0'
            ;;
        default)
            escape='0;39'
            ;;
        default-bold)
            escape='1;39'
            ;;
        black)
            escape='0;30'
            ;;
        black-bold)
            escape='1;30'
            ;;
        blue)
            escape='0;34'
            ;;
        blue-bold)
            escape='1;34'
            ;;
        cyan)
            escape='0;36'
            ;;
        cyan-bold)
            escape='1;36'
            ;;
        green)
            escape='0;32'
            ;;
        green-bold)
            escape='1;32'
            ;;
        magenta)
            escape='0;35'
            ;;
        magenta-bold)
            escape='1;35'
            ;;
        red)
            escape='0;31'
            ;;
        red-bold)
            escape='1;31'
            ;;
        yellow)
            escape='0;33'
            ;;
        yellow-bold)
            escape='1;33'
            ;;
        white)
            escape='0;97'
            ;;
        white-bold)
            escape='1;97'
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
    printf '\033[%sm' "$escape"
    return 0
}

__koopa_h() { # {{{1
    # """
    # Koopa header.
    # @note Updated 2021-03-31.
    # """
    local emoji level prefix x
    level="${1:?}"
    shift 1
    case "$level" in
        1)
            _koopa_print ''
            prefix='#'
            ;;
        2)
            prefix='##'
            ;;
        3)
            prefix='###'
            ;;
        4)
            prefix='####'
            ;;
        5)
            prefix='#####'
            ;;
        6)
            prefix='######'
            ;;
        7)
            prefix='#######'
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
    emoji="$(__koopa_acid_emoji)"
    __koopa_msg 'magenta' 'default' "${emoji} ${prefix}" "$@"
    return 0
}

__koopa_msg() { # {{{1
    # """
    # Koopa standard message.
    # @note Updated 2021-03-31.
    # """
    local c1 c2 emoji nc prefix string x
    c1="$(__koopa_ansi_escape "${1:?}")"
    c2="$(__koopa_ansi_escape "${2:?}")"
    nc="$(__koopa_ansi_escape 'nocolor')"
    prefix="${3:?}"
    shift 3
    for string in "$@"
    do
        x="${c1}${prefix}${nc} ${c2}${string}${nc}"
        _koopa_print "$x"
    done
    return 0
}

__koopa_print_ansi() { # {{{1
    # """
    # Print a colored line in console.
    # @note Updated 2020-07-30.
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
    local color nocolor string
    color="$(__koopa_ansi_escape "${1:?}")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    shift 1
    for string in "$@"
    do
        printf '%s%b%s\n' "$color" "$string" "$nocolor"
    done
    return 0
}

__koopa_status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2020-07-20.
    # """
    local color nocolor label string x
    [ "$#" -ge 3 ] || return 1
    label="$(printf '%10s\n' "${1:?}")"
    color="$(__koopa_ansi_escape "${2:?}")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    shift 2
    for string in "$@"
    do
        x="${color}${label}${nocolor} | ${string}"
        _koopa_print "$x"
    done
    return 0
}

_koopa_alert() { # {{{1
    # """
    # Alert message.
    # @note Updated 2021-03-31.
    # """
    __koopa_msg 'default' 'default' '→' "$@"
    return 0
}

_koopa_alert_coffee_time() { # {{{1
    # """
    # Alert that it's coffee time.
    # @note Updated 2021-03-31.
    # """
    _koopa_alert_note 'This step takes a while. Time for a coffee break! ☕'
    return 0
}

_koopa_alert_info() { # {{{1
    # """
    # Alert info message.
    # @note Updated 2021-03-30.
    # """
    __koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

_koopa_alert_not_installed() { # {{{1
    # """
    # Note that program is not installed.
    # @note Updated 2021-05-07.
    # """
    local name prefix
    [ "$#" -gt 0 ] || return 1
    name="${1:?}"
    prefix="${2:-}"
    x="${name} is not installed"
    if [ -n "$prefix" ]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    _koopa_alert_note "$x"
    return 0
}

_koopa_alert_note() { # {{{1
    # """
    # General note.
    # @note Updated 2020-07-01.
    # """
    __koopa_msg 'yellow' 'default' '**' "$@"
    return 0
}

_koopa_alert_restart() { # {{{1
    # """
    # Inform the user that they should restart shell.
    # @note Updated 2021-03-31.
    # """
    _koopa_alert_note 'Restart the shell.'
    return 0
}

_koopa_alert_success() { # {{{1
    # """
    # Alert success message.
    # @note Updated 2021-03-31.
    # """
    __koopa_msg 'green-bold' 'green' '✓' "$@"
    return 0
}

_koopa_dl() { # {{{1
    # """
    # Definition list.
    # @note Updated 2020-07-20.
    # """
    [ "$#" -ge 2 ] || return 1
    while [ "$#" -ge 2 ]
    do
        __koopa_msg 'default-bold' 'default' "${1:?}:" "${2:?}"
        shift 2
    done
    return 0
}

_koopa_h1() { # {{{1
    __koopa_h 1 "$@"
    return 0
}

_koopa_h2() { # {{{1
    __koopa_h 2 "$@"
    return 0
}

_koopa_h3() { # {{{1
    __koopa_h 3 "$@"
    return 0
}

_koopa_h4() { # {{{1
    __koopa_h 4 "$@"
    return 0
}

_koopa_h5() { # {{{1
    __koopa_h 5 "$@"
    return 0
}

_koopa_h6() { # {{{1
    __koopa_h 6 "$@"
    return 0
}

_koopa_h7() { # {{{1
    __koopa_h 7 "$@"
    return 0
}

_koopa_invalid_arg() { # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2021-05-05.
    # """
    local arg x
    if [ "$#" -gt 0 ]
    then
        arg="${1:-}"
        if _koopa_str_match_posix "$arg" '--'
        then
            _koopa_warning "Use '--arg=VALUE' not '--arg VALUE'."
        fi
        x="Invalid argument: '${arg}'."
    else
        x='Invalid argument.'
    fi
    _koopa_stop "$x"
}

_koopa_missing_arg() { # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2020-07-01.
    # """
    _koopa_stop 'Missing required argument.'
}

_koopa_print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2020-07-05.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    local string
    if [ "$#" -eq 0 ]
    then
        printf '\n'
        return 0
    fi
    for string in "$@"
    do
        printf '%b\n' "$string"
    done
    return 0
}

_koopa_print_black() { # {{{1
    __koopa_print_ansi 'black' "$@"
    return 0
}

_koopa_print_black_bold() { # {{{1
    __koopa_print_ansi 'black-bold' "$@"
    return 0
}

_koopa_print_blue() { # {{{1
    __koopa_print_ansi 'blue' "$@"
    return 0
}

_koopa_print_blue_bold() { # {{{1
    __koopa_print_ansi 'blue-bold' "$@"
    return 0
}

_koopa_print_cyan() { # {{{1
    __koopa_print_ansi 'cyan' "$@"
    return 0
}

_koopa_print_cyan_bold() { # {{{1
    __koopa_print_ansi 'cyan-bold' "$@"
    return 0
}

_koopa_print_default() { # {{{1
    __koopa_print_ansi 'default' "$@"
    return 0
}

_koopa_print_default_bold() { # {{{1
    __koopa_print_ansi 'default-bold' "$@"
    return 0
}

_koopa_print_green() { # {{{1
    __koopa_print_ansi 'green' "$@"
    return 0
}

_koopa_print_green_bold() { # {{{1
    __koopa_print_ansi 'green-bold' "$@"
    return 0
}

_koopa_print_magenta() { # {{{1
    __koopa_print_ansi 'magenta' "$@"
    return 0
}

_koopa_print_magenta_bold() { # {{{1
    __koopa_print_ansi 'magenta-bold' "$@"
    return 0
}

_koopa_print_red() { # {{{1
    __koopa_print_ansi 'red' "$@"
    return 0
}

_koopa_print_red_bold() { # {{{1
    __koopa_print_ansi 'red-bold' "$@"
    return 0
}

_koopa_print_yellow() { # {{{1
    __koopa_print_ansi 'yellow' "$@"
    return 0
}

_koopa_print_yellow_bold() { # {{{1
    __koopa_print_ansi 'yellow-bold' "$@"
    return 0
}

_koopa_print_white() { # {{{1
    __koopa_print_ansi 'white' "$@"
    return 0
}

_koopa_print_white_bold() { # {{{1
    __koopa_print_ansi 'white-bold' "$@"
    return 0
}

_koopa_status_fail() { # {{{1
    # """
    # FAIL status.
    # @note Updated 2020-07-20.
    # """
    __koopa_status 'FAIL' 'red' "$@" >&2
    return 0
}

_koopa_status_note() { # {{{1
    # """
    # NOTE status.
    # @note Updated 2020-07-20.
    # """
    __koopa_status 'NOTE' 'yellow' "$@"
    return 0
}

_koopa_status_ok() { # {{{1
    # """
    # OK status.
    # @note Updated 2020-07-20.
    # """
    __koopa_status 'OK' 'green' "$@"
    return 0
}

_koopa_stop() { # {{{1
    # """
    # Stop with an error message, and exit.
    # @note Updated 2021-01-19.
    # """
    __koopa_msg 'red-bold' 'red' '!! Error:' "$@" >&2
    exit 1
}

_koopa_warning() { # {{{1
    # """
    # Warning message.
    # @note Updated 2021-01-19.
    # """
    __koopa_msg 'magenta-bold' 'magenta' '!! Warning:' "$@" >&2
    return 0
}

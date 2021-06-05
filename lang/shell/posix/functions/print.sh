#!/bin/sh

__koopa_acid_emoji() { # {{{1
    # """
    # Acid Genomics test tube emoji.
    # @note Updated 2021-06-03.
    #
    # Previous versions defaulted to using the '🐢' turtle.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_print '🧪'
}

__koopa_ansi_escape() { # {{{1
    # """
    # ANSI escape codes.
    # @note Updated 2020-07-05.
    # """
    local escape
    [ "$#" -eq 1 ] || return 1
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
            return 1
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
    [ "$#" -ge 2 ] || return 1
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
            return 1
            ;;
    esac
    emoji="$(__koopa_acid_emoji)"
    __koopa_msg 'magenta' 'default' "${emoji} ${prefix}" "$@"
    return 0
}

__koopa_msg() { # {{{1
    # """
    # Koopa standard message.
    # @note Updated 2021-06-05.
    # """
    local c1 c2 emoji nc prefix string x
    [ "$#" -ge 4 ] || return 1
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
    [ "$#" -ge 2 ] || return 1
    color="$(__koopa_ansi_escape "${1:?}")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    shift 1
    for string in "$@"
    do
        printf '%s%b%s\n' "$color" "$string" "$nocolor"
    done
    return 0
}

_koopa_alert() { # {{{1
    # """
    # Alert message.
    # @note Updated 2021-03-31.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_msg 'default' 'default' '→' "$@"
    return 0
}

_koopa_alert_info() { # {{{1
    # """
    # Alert info message.
    # @note Updated 2021-03-30.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_msg 'cyan' 'default' 'ℹ︎' "$@"
    return 0
}

_koopa_alert_is_installed() { # {{{1
    # """
    # Alert the user that a program is installed.
    # @note Updated 2021-06-03.
    # """
    local name prefix
    [ "$#" -le 2 ] || return 1
    name="${1:?}"
    prefix="${2:-}"
    x="${name} is installed"
    if [ -n "$prefix" ]
    then
        x="${x} at '${prefix}'"
    fi
    x="${x}."
    _koopa_alert_note "$x"
    return 0
}

_koopa_alert_is_not_installed() { # {{{1
    # """
    # Alert the user that a program is not installed.
    # @note Updated 2021-06-03.
    # """
    local name prefix
    [ "$#" -le 2 ] || return 1
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
    [ "$#" -gt 0 ] || return 1
    __koopa_msg 'yellow' 'default' '**' "$@"
    return 0
}

_koopa_alert_success() { # {{{1
    # """
    # Alert success message.
    # @note Updated 2021-03-31.
    # """
    [ "$#" -gt 0 ] || return 1
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
    [ "$#" -gt 0 ] || return 1
    __koopa_h 1 "$@"
    return 0
}

_koopa_h2() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_h 2 "$@"
    return 0
}

_koopa_h3() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_h 3 "$@"
    return 0
}

_koopa_h4() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_h 4 "$@"
    return 0
}

_koopa_h5() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_h 5 "$@"
    return 0
}

_koopa_h6() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_h 6 "$@"
    return 0
}

_koopa_h7() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_h 7 "$@"
    return 0
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
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'black' "$@"
    return 0
}

_koopa_print_black_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'black-bold' "$@"
    return 0
}

_koopa_print_blue() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'blue' "$@"
    return 0
}

_koopa_print_blue_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'blue-bold' "$@"
    return 0
}

_koopa_print_cyan() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'cyan' "$@"
    return 0
}

_koopa_print_cyan_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'cyan-bold' "$@"
    return 0
}

_koopa_print_default() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'default' "$@"
    return 0
}

_koopa_print_default_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'default-bold' "$@"
    return 0
}

_koopa_print_green() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'green' "$@"
    return 0
}

_koopa_print_green_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'green-bold' "$@"
    return 0
}

_koopa_print_magenta() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'magenta' "$@"
    return 0
}

_koopa_print_magenta_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'magenta-bold' "$@"
    return 0
}

_koopa_print_red() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'red' "$@"
    return 0
}

_koopa_print_red_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'red-bold' "$@"
    return 0
}

_koopa_print_yellow() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'yellow' "$@"
    return 0
}

_koopa_print_yellow_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'yellow-bold' "$@"
    return 0
}

_koopa_print_white() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'white' "$@"
    return 0
}

_koopa_print_white_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi 'white-bold' "$@"
    return 0
}

_koopa_warning() { # {{{1
    # """
    # Warning message.
    # @note Updated 2021-01-19.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_msg 'magenta-bold' 'magenta' '!! Warning:' "$@" >&2
    return 0
}

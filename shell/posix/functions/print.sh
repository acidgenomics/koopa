#!/bin/sh
# shellcheck disable=SC2039

__koopa_ansi_escape() {  # {{{1
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
            >&2 _koopa_print "WARNING: Unsupported color: '${1}'."
            escape='0'
            ;;
    esac
    printf '\033[%sm' "$escape"
    return 0
}

__koopa_emoji() {  # {{{1
    # """
    # Koopa turtle emoji.
    # @note Updated 2020-03-05.
    # """
    _koopa_print '🐢'
}

__koopa_h() {  # {{{1
    # """
    # Koopa header.
    # @note Updated 2020-03-05.
    # """
    local level prefix string
    level="${1:?}"
    string="${2:?}"
    case "$level" in
        1)
            prefix='=>'
            _koopa_print
            ;;
        2)
            prefix='==>'
            ;;
        3)
            prefix='===>'
            ;;
        4)
            prefix='====>'
            ;;
        5)
            prefix='=====>'
            ;;
        6)
            prefix='======>'
            ;;
        7)
            prefix='=======>'
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
    __koopa_msg "$string" "$prefix" 'magenta'
}

__koopa_msg() {
    # """
    # Koopa standard message.
    # @note Updated 2020-03-05.
    # """
    local color1 color2 emoji nocolor prefix string x

    string="${1:?}"
    prefix="${2:-}"
    color1="${3:-default}"
    color1="$(__koopa_ansi_escape "$color1")"
    color2="${4:-default}"
    color2="$(__koopa_ansi_escape "$color2")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    emoji="$(__koopa_emoji)"

    x="${emoji}"
    if [ -n "$prefix" ]
    then
        x="${x} ${color1}${prefix}${nocolor}"
    fi
    x="${x} ${color2}${string}${nocolor}"

    _koopa_print "$x"
}

__koopa_print_ansi() {  # {{{1
    # """
    # Print a colored line in console.
    # @note Updated 2020-03-05.
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
    local color
    color="$(_koopa_ansi_escape "${1:?}")"
    local string
    string="${2:?}"
    local nocolor
    nocolor="$(_koopa_ansi_escape 'nocolor')"
    printf '%s%b%s\n' "$color" "$string" "$nocolor"
    return 0
}

__koopa_status() {  # {{{1
    # """
    # Koopa status.
    # @note Updated 2020-03-05.
    # """
    local color nocolor label string x
    string="${1:?}"
    label="$(printf '%10s\n' "${2:?}")"
    color="$(__koopa_ansi_escape "${3:?}")"
    nocolor="$(__koopa_ansi_escape 'nocolor')"
    x="${color}${label}${nocolor} | ${string}"
    _koopa_print "$x"
}



_koopa_coffee_time() {  # {{{1
    # """
    # Coffee time.
    # @note Updated 2020-03-05.
    # """
    _koopa_note 'This step takes a while. Time for a coffee break! ☕☕'
}

_koopa_dl() {
    # """
    # Koopa definition list.
    # @note Updated 2020-03-05.
    # """
    __koopa_msg "${1:?}: ${2:?}"
}

_koopa_h1() {  # {{{1
    __koopa_h 1 "$@"
}

_koopa_h2() {  # {{{1
    __koopa_h 2 "$@"
}

_koopa_h3() {  # {{{1
    __koopa_h 3 "$@"
}

_koopa_h4() {  # {{{1
    __koopa_h 4 "$@"
}

_koopa_h5() {  # {{{1
    __koopa_h 5 "$@"
}

_koopa_h6() {  # {{{1
    __koopa_h 6 "$@"
}

_koopa_h7() {  # {{{1
    __koopa_h 7 "$@"
}

_koopa_info() {  # {{{1
    # """
    # General info.
    # @note Updated 2020-03-05.
    # """
    __koopa_msg "${1:-}" '--'
}

_koopa_install_start() {  # {{{1
    # """
    # Inform the user about start of installation.
    # @note Updated 2020-02-20.
    # """
    local name
    name="${1:?}"
    local prefix
    prefix="${2:-}"
    local msg
    if [ -n "$prefix" ]
    then
        msg="Installing ${name} at '${prefix}'."
    else
        msg="Installing ${name}."
    fi
    _koopa_h1 "$msg"
}

_koopa_install_success() {  # {{{1
    # """
    # Installation success message.
    # @note Updated 2020-03-05.
    # """
    _koopa_success "Installation of ${1:?} was successful."
}

_koopa_invalid_arg() {  # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2020-03-05.
    # """
    _koopa_stop "Invalid argument: '${1:?}'."
}

_koopa_missing_arg() {  # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2020-03-05.
    # """
    _koopa_stop 'Missing required argument.'
}

_koopa_note() {  # {{{1
    # """
    # General note.
    # @note Updated 2020-03-05.
    # """
    __koopa_msg "${1:?}" '**' 'yellow'
}

_koopa_print() {  # {{{1
    # """
    # Print a string.
    # @note Updated 2020-03-05.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    printf '%b\n' "${1:-}"
    return 0
}

_koopa_print_black() {  # {{{1
    __koopa_print_ansi 'black' "${1:?}"
}

_koopa_print_black_bold() {  # {{{1
    __koopa_print_ansi 'black-bold' "${1:?}"
}

_koopa_print_blue() {  # {{{1
    __koopa_print_ansi 'blue' "${1:?}"
}

_koopa_print_blue_bold() {  # {{{1
    __koopa_print_ansi 'blue-bold' "${1:?}"
}

_koopa_print_cyan() {  # {{{1
    __koopa_print_ansi 'cyan' "${1:?}"
}

_koopa_print_cyan_bold() {  # {{{1
    __koopa_print_ansi 'cyan-bold' "${1:?}"
}

_koopa_print_default() {  # {{{1
    __koopa_print_ansi 'default' "${1:?}"
}

_koopa_print_default_bold() {  # {{{1
    __koopa_print_ansi 'default-bold' "${1:?}"
}

_koopa_print_green() {  # {{{1
    __koopa_print_ansi 'green' "${1:?}"
}

_koopa_print_green_bold() {  # {{{1
    __koopa_print_ansi 'green-bold' "${1:?}"
}

_koopa_print_magenta() {  # {{{1
    __koopa_print_ansi 'magenta' "${1:?}"
}

_koopa_print_magenta_bold() {  # {{{1
    __koopa_print_ansi 'magenta-bold' "${1:?}"
}

_koopa_print_red() {  # {{{1
    __koopa_print_ansi 'red' "${1:?}"
}

_koopa_print_red_bold() {  # {{{1
    __koopa_print_ansi 'red-bold' "${1:?}"
}

_koopa_print_yellow() {  # {{{1
    __koopa_print_ansi 'yellow' "${1:?}"
}

_koopa_print_yellow_bold() {  # {{{1
    __koopa_print_ansi 'yellow-bold' "${1:?}"
}

_koopa_print_white() {  # {{{1
    __koopa_print_ansi 'white' "${1:?}"
}

_koopa_print_white_bold() {  # {{{1
    __koopa_print_ansi 'white-bold' "${1:?}"
}

_koopa_restart() {  # {{{1
    # """
    # Inform the user that they should restart shell.
    # @note Updated 2020-02-20.
    # """
    _koopa_note 'Restart the shell.'
}

_koopa_status_fail() {  # {{{1
    >&2 __koopa_status "${1:?}" 'FAIL' 'red'
}

_koopa_status_note() {  # {{{1
    __koopa_status "${1:?}" 'NOTE' 'yellow'
}

_koopa_status_ok() {  # {{{1
    __koopa_status "${1:?}" 'OK' 'green'
}

_koopa_stop() {  # {{{1
    # """
    # Stop with an error message, and exit.
    # @note Updated 2020-03-05.
    # """
    >&2 __koopa_msg "${1:?}" '!! ERROR:' 'red-bold' 'red'
    exit 1
}

_koopa_success() {  # {{{1
    # """
    # Success message.
    # @note Updated 2020-03-05.
    # """
    __koopa_msg "${1:?}" 'OK' 'green-bold' 'green'
}

_koopa_uninstall_start() {  # {{{1
    # """
    # Inform the user about start of uninstall.
    # @note Updated 2020-03-05.
    # """
    local name
    name="${1:?}"
    local prefix
    prefix="${2:-}"
    local msg
    if [ -n "$prefix" ]
    then
        msg="Uninstalling ${name} at '${prefix}'."
    else
        msg="Uninstalling ${name}."
    fi
    _koopa_h1 "$msg"
}

_koopa_uninstall_success() {  # {{{1
    # """
    # Uninstall success message.
    # @note Updated 2020-03-05.
    # """
    _koopa_success "Uninstallation of ${1:?} was successful."
}

_koopa_update_start() {  # {{{1
    # """
    # Inform the user about start of update.
    # @note Updated 2020-03-05.
    # """
    local name
    name="${1:?}"
    local prefix
    prefix="${2:-}"
    local msg
    if [ -n "$prefix" ]
    then
        msg="Updating ${name} at '${prefix}'."
    else
        msg="Updating ${name}."
    fi
    _koopa_h1 "$msg"
}

_koopa_update_success() {  # {{{1
    # """
    # Update success message.
    # @note Updated 2020-03-05.
    # """
    _koopa_success "Update of ${1:?} was successful."
}

_koopa_warning() {  # {{{1
    # """
    # Warning message.
    # @note Updated 2020-03-05.
    # """
    >&2 __koopa_msg "${1:?}" '!! WARNING:' 'yellow-bold' 'yellow'
}

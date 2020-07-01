#!/bin/sh
# shellcheck disable=SC2039

__koopa_ansi_escape() { # {{{1
    # """
    # ANSI escape codes.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -eq 1 ] || return 1
    local escape
    case "${1:?}" in
        nocolor)
            escape="0"
            ;;
        default)
            escape="0;39"
            ;;
        default-bold)
            escape="1;39"
            ;;
        black)
            escape="0;30"
            ;;
        black-bold)
            escape="1;30"
            ;;
        blue)
            escape="0;34"
            ;;
        blue-bold)
            escape="1;34"
            ;;
        cyan)
            escape="0;36"
            ;;
        cyan-bold)
            escape="1;36"
            ;;
        green)
            escape="0;32"
            ;;
        green-bold)
            escape="1;32"
            ;;
        magenta)
            escape="0;35"
            ;;
        magenta-bold)
            escape="1;35"
            ;;
        red)
            escape="0;31"
            ;;
        red-bold)
            escape="1;31"
            ;;
        yellow)
            escape="0;33"
            ;;
        yellow-bold)
            escape="1;33"
            ;;
        white)
            escape="0;97"
            ;;
        white-bold)
            escape="1;97"
            ;;
        *)
            >&2 _koopa_print "WARNING: Unsupported color: '${1}'."
            escape="0"
            ;;
    esac
    printf "\033[%sm" "$escape"
    return 0
}

__koopa_emoji() { # {{{1
    # """
    # Koopa turtle emoji.
    # @note Updated 2020-06-30.
    # """
    _koopa_print "🐢"
}

__koopa_h() { # {{{1
    # """
    # Koopa header.
    # @note Updated 2020-06-30.
    # """
    [ "$#" -gt 1 ] || return 1
    local level prefix string
    level="${1:?}"
    shift 1
    case "$level" in
        1)
            _koopa_print
            prefix="=>"
            ;;
        2)
            prefix="==>"
            ;;
        3)
            prefix="===>"
            ;;
        4)
            prefix="====>"
            ;;
        5)
            prefix="=====>"
            ;;
        6)
            prefix="======>"
            ;;
        7)
            prefix="=======>"
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
    __koopa_msg "magenta" "default" "$prefix" "$@"
    return 0
}

__koopa_msg() {
    # """
    # Koopa standard message.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    local c1 c2 emoji nc prefix string x
    emoji="$(__koopa_emoji)"
    c1="$(__koopa_ansi_escape "${1:?}")"
    c2="$(__koopa_ansi_escape "${2:?}")"
    nc="$(__koopa_ansi_escape "nocolor")"
    prefix="${3:?}"
    shift 3
    for string in "$@"
    do
        x="${emoji} ${c1}${prefix}${nc} ${c2}${string}${nc}"
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
    [ "$#" -ge 2 ] || return 1
    local color nocolor string
    color="$(__koopa_ansi_escape "${1:?}")"
    nocolor="$(__koopa_ansi_escape "nocolor")"
    shift 1
    for string in "$@"
    do
        printf "%s%b%s\n" "$color" "$string" "$nocolor"
    done
    return 0
}

__koopa_status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -ge 3 ] || return 1
    local color nocolor label string x
    label="$(printf "%10s\n" "${1:?}")"
    color="$(__koopa_ansi_escape "${2:?}")"
    nocolor="$(__koopa_ansi_escape "nocolor")"
    shift 2
    for string in "$@"
    do
        x="${color}${label}${nocolor} | ${string}"
        _koopa_print "$x"
    done
    return 0
}



_koopa_coffee_time() { # {{{1
    # """
    # Coffee time.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_note 'This step takes a while. Time for a coffee break! ☕☕'
    return 0
}

_koopa_dl() { # {{{1
    # """
    # Definition list.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 2 ] || return 1
    __koopa_msg "default-bold" "default" "${1:?}:" "${2:?}"
}

_koopa_exit() { # {{{1
    # """
    # Exit showing note, without error.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 1 ] || return 1
    _koopa_note "${1:?}"
    exit 0
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

_koopa_info() { # {{{1
    # """
    # General info.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_msg "default" "default" "--" "$@"
    return 0
}

_koopa_install_start() { # {{{1
    # """
    # Inform the user about start of installation.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    local msg name version prefix
    name="${1:?}"
    version=
    prefix=
    if [ "$#" -eq 2 ]
    then
        prefix="${2:?}"
    elif [ "$#" -eq 3 ]
    then
        version="${2:?}"
        prefix="${3:?}"
    elif [ "$#" -ge 4 ]
    then
        _koopa_stop "Invalid number of arguments."
    fi
    if [ -n "$prefix" ] && [ -n "$version" ]
    then
        msg="Installing ${name} ${version} at '${prefix}'."
    elif [ -n "$prefix" ]
    then
        msg="Installing ${name} at '${prefix}'."
    else
        msg="Installing ${name}."
    fi
    _koopa_h1 "$msg"
    return 0
}

_koopa_install_success() { # {{{1
    # """
    # Installation success message.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 1 ] || return 1
    _koopa_success "Installation of ${1:?} was successful."
    return 0
}

_koopa_invalid_arg() { # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 1 ] || return 1
    _koopa_stop "Invalid argument: '${1:?}'."
}

_koopa_missing_arg() { # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_stop "Missing required argument."
}

_koopa_note() { # {{{1
    # """
    # General note.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_msg "yellow" "default" "**" "$@"
    return 0
}

_koopa_print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2020-07-01.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    [ "$#" -eq 0 ] && printf "\n"
    local string
    for string in "$@"
    do
        printf "%b\n" "$string"
    done
    return 0
}

_koopa_print_black() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "black" "$@"
    return 0
}

_koopa_print_black_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "black-bold" "$@"
    return 0
}

_koopa_print_blue() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "blue" "$@"
    return 0
}

_koopa_print_blue_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "blue-bold" "$@"
    return 0
}

_koopa_print_cyan() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "cyan" "$@"
    return 0
}

_koopa_print_cyan_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "cyan-bold" "$@"
    return 0
}

_koopa_print_default() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "default" "$@"
    return 0
}

_koopa_print_default_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "default-bold" "$@"
    return 0
}

_koopa_print_green() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "green" "$@"
    return 0
}

_koopa_print_green_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "green-bold" "$@"
    return 0
}

_koopa_print_magenta() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "magenta" "$@"
    return 0
}

_koopa_print_magenta_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "magenta-bold" "$@"
    return 0
}

_koopa_print_red() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "red" "$@"
    return 0
}

_koopa_print_red_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "red-bold" "$@"
    return 0
}

_koopa_print_yellow() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "yellow" "$@"
    return 0
}

_koopa_print_yellow_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "yellow-bold" "$@"
    return 0
}

_koopa_print_white() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "white" "$@"
    return 0
}

_koopa_print_white_bold() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_print_ansi "white-bold" "$@"
    return 0
}

_koopa_restart() { # {{{1
    # """
    # Inform the user that they should restart shell.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 0 ] || return 1
    _koopa_note "Restart the shell."
    return 0
}

_koopa_status_fail() { # {{{1
    [ "$#" -gt 0 ] || return 1
    >&2 __koopa_status "FAIL" "red" "$@"
    return 0
}

_koopa_status_note() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_status "NOTE" "yellow" "$@"
    return 0
}

_koopa_status_ok() { # {{{1
    [ "$#" -gt 0 ] || return 1
    __koopa_status "OK" "green" "$@"
    return 0
}

_koopa_stop() { # {{{1
    # """
    # Stop with an error message, and exit.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    >&2 __koopa_msg "red-bold" "red" "Error:" "$@"
    exit 1
}

_koopa_success() { # {{{1
    # """
    # Success message.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_msg "green-bold" "green" "OK" "$@"
    return 0
}

_koopa_uninstall_start() { # {{{1
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
    return 0
}

_koopa_uninstall_success() { # {{{1
    # """
    # Uninstall success message.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 1 ] || return 1
    _koopa_success "Uninstallation of ${1:?} was successful."
    return 0
}

_koopa_update_start() { # {{{1
    # """
    # Inform the user about start of update.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    local name msg prefix
    name="${1:?}"
    prefix="${2:-}"
    if [ -n "$prefix" ]
    then
        msg="Updating ${name} at '${prefix}'."
    else
        msg="Updating ${name}."
    fi
    _koopa_h1 "$msg"
    return 0
}

_koopa_update_success() { # {{{1
    # """
    # Update success message.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -eq 1 ] || return 1
    _koopa_success "Update of ${1:?} was successful."
    return 0
}

_koopa_warning() { # {{{1
    # """
    # Warning message.
    # @note Updated 2020-07-01.
    # """
    [ "$#" -gt 0 ] || return 1
    >&2 __koopa_msg "yellow-bold" "yellow" "Warning:" "$@"
    return 0
}

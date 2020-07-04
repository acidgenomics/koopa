#!/bin/sh
# shellcheck disable=SC2039

koopa::_ansi_escape() { # {{{1
    # """
    # ANSI escape codes.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_args_eq "$#" 1
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
            koopa::print "WARNING: Unsupported color: '${1}'." >&2
            escape="0"
            ;;
    esac
    printf "\033[%sm" "$escape"
    return 0
}

koopa::_emoji() { # {{{1
    # """
    # Koopa turtle emoji.
    # @note Updated 2020-06-30.
    # """
    koopa::print "🐢"
}

koopa::_h() { # {{{1
    # """
    # Koopa header.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_args_ge "$#" 2
    local level prefix string
    level="${1:?}"
    shift 1
    case "$level" in
        1)
            koopa::print
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
            koopa::invalid_arg "$1"
            ;;
    esac
    koopa::_msg "magenta" "default" "$prefix" "$@"
    return 0
}

koopa::_msg() {
    # """
    # Koopa standard message.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    local c1 c2 emoji nc prefix string x
    emoji="$(koopa::_emoji)"
    c1="$(koopa::_ansi_escape "${1:?}")"
    c2="$(koopa::_ansi_escape "${2:?}")"
    nc="$(koopa::_ansi_escape "nocolor")"
    prefix="${3:?}"
    shift 3
    for string in "$@"
    do
        x="${emoji} ${c1}${prefix}${nc} ${c2}${string}${nc}"
        koopa::print "$x"
    done
    return 0
}

koopa::_print_ansi() { # {{{1
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
    koopa::assert_has_args_ge "$#" 2
    local color nocolor string
    color="$(koopa::_ansi_escape "${1:?}")"
    nocolor="$(koopa::_ansi_escape "nocolor")"
    shift 1
    for string in "$@"
    do
        printf "%s%b%s\n" "$color" "$string" "$nocolor"
    done
    return 0
}

koopa::_status() { # {{{1
    # """
    # Koopa status.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_ge "$#" 3
    local color nocolor label string x
    label="$(printf "%10s\n" "${1:?}")"
    color="$(koopa::_ansi_escape "${2:?}")"
    nocolor="$(koopa::_ansi_escape "nocolor")"
    shift 2
    for string in "$@"
    do
        x="${color}${label}${nocolor} | ${string}"
        koopa::print "$x"
    done
    return 0
}



koopa::coffee_time() { # {{{1
    # """
    # Coffee time.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::note 'This step takes a while. Time for a coffee break! ☕☕'
    return 0
}

koopa::dl() { # {{{1
    # """
    # Definition list.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 2
    koopa::_msg "default-bold" "default" "${1:?}:" "${2:?}"
}

koopa::exit() { # {{{1
    # """
    # Exit showing note, without error.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::note "${1:?}"
    exit 0
}

koopa::h1() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 1 "$@"
    return 0
}

koopa::h2() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 2 "$@"
    return 0
}

koopa::h3() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 3 "$@"
    return 0
}

koopa::h4() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 4 "$@"
    return 0
}

koopa::h5() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 5 "$@"
    return 0
}

koopa::h6() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 6 "$@"
    return 0
}

koopa::h7() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_h 7 "$@"
    return 0
}

koopa::info() { # {{{1
    # """
    # General info.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    koopa::_msg "default" "default" "--" "$@"
    return 0
}

koopa::install_start() { # {{{1
    # """
    # Inform the user about start of installation.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
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
        koopa::stop "Invalid number of arguments."
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
    koopa::h1 "$msg"
    return 0
}

koopa::install_success() { # {{{1
    # """
    # Installation success message.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::success "Installation of ${1:?} was successful."
    return 0
}

koopa::invalid_arg() { # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::stop "Invalid argument: '${1:?}'."
}

koopa::missing_arg() { # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::stop "Missing required argument."
}

koopa::note() { # {{{1
    # """
    # General note.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    koopa::_msg "yellow" "default" "**" "$@"
    return 0
}

koopa::print() { # {{{1
    # """
    # Print a string.
    # @note Updated 2020-07-03.
    #
    # printf vs. echo
    # - http://www.etalabs.net/sh_tricks.html
    # - https://unix.stackexchange.com/questions/65803
    # - https://www.freecodecamp.org/news/
    #       how-print-newlines-command-line-output/
    # """
    if [ "$#" -eq 0 ]
    then
        printf "\n"
        return 0
    fi
    local string
    for string in "$@"
    do
        printf "%b\n" "$string"
    done
    return 0
}

koopa::print_black() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "black" "$@"
    return 0
}

koopa::print_black_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "black-bold" "$@"
    return 0
}

koopa::print_blue() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "blue" "$@"
    return 0
}

koopa::print_blue_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "blue-bold" "$@"
    return 0
}

koopa::print_cyan() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "cyan" "$@"
    return 0
}

koopa::print_cyan_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "cyan-bold" "$@"
    return 0
}

koopa::print_default() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "default" "$@"
    return 0
}

koopa::print_default_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "default-bold" "$@"
    return 0
}

koopa::print_green() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "green" "$@"
    return 0
}

koopa::print_green_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "green-bold" "$@"
    return 0
}

koopa::print_magenta() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "magenta" "$@"
    return 0
}

koopa::print_magenta_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "magenta-bold" "$@"
    return 0
}

koopa::print_red() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "red" "$@"
    return 0
}

koopa::print_red_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "red-bold" "$@"
    return 0
}

koopa::print_yellow() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "yellow" "$@"
    return 0
}

koopa::print_yellow_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "yellow-bold" "$@"
    return 0
}

koopa::print_white() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "white" "$@"
    return 0
}

koopa::print_white_bold() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_print_ansi "white-bold" "$@"
    return 0
}

koopa::restart() { # {{{1
    # """
    # Inform the user that they should restart shell.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_no_args "$#"
    koopa::note "Restart the shell."
    return 0
}

koopa::status_fail() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_status "FAIL" "red" "$@" >&2
    return 0
}

koopa::status_note() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_status "NOTE" "yellow" "$@"
    return 0
}

koopa::status_ok() { # {{{1
    koopa::assert_has_args "$#"
    koopa::_status "OK" "green" "$@"
    return 0
}

koopa::stop() { # {{{1
    # """
    # Stop with an error message, and exit.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    koopa::_msg "red-bold" "red" "Error:" "$@" >&2
    exit 1
}

koopa::success() { # {{{1
    # """
    # Success message.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    koopa::_msg "green-bold" "green" "OK" "$@"
    return 0
}

koopa::uninstall_start() { # {{{1
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
    koopa::h1 "$msg"
    return 0
}

koopa::uninstall_success() { # {{{1
    # """
    # Uninstall success message.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::success "Uninstallation of ${1:?} was successful."
    return 0
}

koopa::update_start() { # {{{1
    # """
    # Inform the user about start of update.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    local name msg prefix
    name="${1:?}"
    prefix="${2:-}"
    if [ -n "$prefix" ]
    then
        msg="Updating ${name} at '${prefix}'."
    else
        msg="Updating ${name}."
    fi
    koopa::h1 "$msg"
    return 0
}

koopa::update_success() { # {{{1
    # """
    # Update success message.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_eq "$#" 1
    koopa::success "Update of ${1:?} was successful."
    return 0
}

koopa::warning() { # {{{1
    # """
    # Warning message.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args "$#"
    koopa::_msg "magenta-bold" "magenta" "Warning:" "$@" >&2
    return 0
}

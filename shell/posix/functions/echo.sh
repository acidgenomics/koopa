#!/bin/sh
# shellcheck disable=SC2039

_koopa_echo_ansi() {                                                      # {{{3
    # """
    # Print a colored line in console.
    # Updated 2019-10-23.
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
    # echo command requires '-e' flag to allow backslash escapes.
    #
    # See also:
    # - https://en.wikipedia.org/wiki/ANSI_escape_code
    # - https://stackoverflow.com/questions/5947742
    # - https://stackoverflow.com/questions/15736223
    # - https://bixense.com/clicolors/
    # """
    local color escape nocolor string
    escape="$1"
    string="$2"
    nocolor="\033[0m"
    color="\033[${escape}m"
    # > printf "%b%s%b\n" "$color" "$nocolor" "$string"
    echo -e "${color}${string}${nocolor}"
}

_koopa_echo_black() {                                                     # {{{3
    _koopa_echo_ansi "0;30" "$1"
}

_koopa_echo_black_bold() {                                                # {{{3
    _koopa_echo_ansi "1;30" "$1"
}

_koopa_echo_blue() {                                                      # {{{3
    _koopa_echo_ansi "0;34" "$1"
}

_koopa_echo_blue_bold() {                                                 # {{{3
    _koopa_echo_ansi "1;34" "$1"
}

_koopa_echo_cyan() {                                                      # {{{3
    _koopa_echo_ansi "0;36" "$1"
}

_koopa_echo_cyan_bold() {                                                 # {{{3
    _koopa_echo_ansi "1;36" "$1"
}

_koopa_echo_green() {                                                     # {{{3
    _koopa_echo_ansi "0;32" "$1"
}

_koopa_echo_green_bold() {                                                # {{{3
    _koopa_echo_ansi "1;32" "$1"
}

_koopa_echo_magenta() {                                                   # {{{3
    _koopa_echo_ansi "0;35" "$1"
}

_koopa_echo_magenta_bold() {                                              # {{{3
    _koopa_echo_ansi "1;35" "$1"
}

_koopa_echo_red() {                                                       # {{{3
    _koopa_echo_ansi "0;31" "$1"
}

_koopa_echo_red_bold() {                                                  # {{{3
    _koopa_echo_ansi "1;31" "$1"
}

_koopa_echo_yellow() {                                                    # {{{3
    _koopa_echo_ansi "0;33" "$1"
}

_koopa_echo_yellow_bold() {                                               # {{{3
    _koopa_echo_ansi "1;33" "$1"
}

_koopa_echo_white() {                                                     # {{{3
    _koopa_echo_ansi "0;37" "$1"
}

_koopa_echo_white_bold() {                                                # {{{3
    _koopa_echo_ansi "1;37" "$1"
}

_koopa_message() {                                                        # {{{3
    # """
    # General message.
    # Updated 2019-10-23.
    # """
    _koopa_echo_cyan_bold "$1"
}

_koopa_note() {                                                           # {{{3
    # """
    # General note message.
    # Updated 2019-10-23.
    # """
    _koopa_echo_magenta_bold "Note: ${1}"
}

_koopa_status_fail() {                                                    # {{{3
    # """
    # Status FAIL.
    # Updated 2019-10-23.
    # """
    _koopa_echo_red "  [FAIL] ${1}"
}

_koopa_status_note() {                                                    # {{{3
    # """
    # Status NOTE.
    # Updated 2019-10-23.
    # """
    _koopa_echo_yellow "  [NOTE] ${1}"
}

_koopa_status_ok() {                                                      # {{{3
    # """
    # Status OK.
    # Updated 2019-10-23.
    # """
    _koopa_echo_green "    [OK] ${1}"
}

_koopa_stop() {                                                           # {{{3
    # """
    # Stop with an error message.
    # Updated 2019-10-23.
    # """
    >&2 _koopa_echo_red_bold "Error: ${1}"
    exit 1
}

_koopa_success() {                                                        # {{{3
    # """
    # Success message.
    # Updated 2019-10-23.
    # """
    _koopa_echo_green_bold "$1"
}

_koopa_warning() {                                                        # {{{3
    # """
    # Warning message.
    # Updated 2019-10-23.
    # """
    >&2 _koopa_echo_yellow_bold "Warning: ${1}"
}

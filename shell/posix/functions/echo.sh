#!/bin/sh
# shellcheck disable=SC2039

_koopa_ansi_escape_code() {  # {{{1
    local escape
    escape="${1:?}"
    case "$escape" in
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
            # This looks purple with Dracula.
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
            >&2 echo "Unsupported ANSI escape code: ${escape}"
            escape="0"
            ;;
    esac
    echo -e "\033[${escape}m"
}

_koopa_ansi_echo() {  # {{{1
    # """
    # Echo a colored line in console.
    # @note Updated 2020-01-17.
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
    # - https://misc.flogisoft.com/bash/tip_colors_and_formatting
    # - https://stackoverflow.com/questions/5947742
    # - https://stackoverflow.com/questions/15736223
    # - https://bixense.com/clicolors/
    # """
    local color
    color="$(_koopa_ansi_escape_code "${1:?}")"
    local nocolor
    nocolor="$(_koopa_ansi_escape_code "nocolor")"
    local string
    string="${2:?}"
    echo -e "${color}${string}${nocolor}"
}

_koopa_coffee_time() {  # {{{1
    # """
    # Coffee time.
    # @note Updated 2020-02-06.
    # """
    _koopa_note "This script takes a while. Time for a coffee! ☕☕"
    return 0
}

_koopa_dl() {
    # """
    # Koopa definition list.
    # @note Updated 2020-02-04.
    # """
    _koopa_info "${1:?}: ${2:?}"
}

_koopa_echo_default() {  # {{{1
    _koopa_ansi_echo "default" "${1:?}"
}

_koopa_echo_default_bold() {  # {{{1
    _koopa_ansi_echo "default-bold" "${1:?}"
}

_koopa_echo_black() {  # {{{1
    _koopa_ansi_echo "black" "${1:?}"
}

_koopa_echo_black_bold() {  # {{{1
    _koopa_ansi_echo "black-bold" "${1:?}"
}

_koopa_echo_blue() {  # {{{1
    _koopa_ansi_echo "blue" "${1:?}"
}

_koopa_echo_blue_bold() {  # {{{1
    _koopa_ansi_echo "blue-bold" "${1:?}"
}

_koopa_echo_cyan() {  # {{{1
    _koopa_ansi_echo "cyan" "${1:?}"
}

_koopa_echo_cyan_bold() {  # {{{1
    _koopa_ansi_echo "cyan-bold" "${1:?}"
}

_koopa_echo_green() {  # {{{1
    _koopa_ansi_echo "green" "${1:?}"
}

_koopa_echo_green_bold() {  # {{{1
    _koopa_ansi_echo "green-bold" "${1:?}"
}

_koopa_echo_magenta() {  # {{{1
    _koopa_ansi_echo "magenta" "${1:?}"
}

_koopa_echo_magenta_bold() {  # {{{1
    _koopa_ansi_echo "magenta-bold" "${1:?}"
}

_koopa_echo_red() {  # {{{1
    _koopa_ansi_echo "red" "${1:?}"
}

_koopa_echo_red_bold() {  # {{{1
    _koopa_ansi_echo "red-bold" "${1:?}"
}

_koopa_echo_yellow() {  # {{{1
    _koopa_ansi_echo "yellow" "${1:?}"
}

_koopa_echo_yellow_bold() {  # {{{1
    _koopa_ansi_echo "yellow-bold" "${1:?}"
}

_koopa_echo_white() {  # {{{1
    _koopa_ansi_echo "white" "${1:?}"
}

_koopa_echo_white_bold() {  # {{{1
    _koopa_ansi_echo "white-bold" "${1:?}"
}

_koopa_emoji() {  # {{{1
    # """
    # Koopa turtle emoji.
    # @note Updated 2020-01-17.
    # """
    echo "🐢"
}

_koopa_h1() {  # {{{1
    # """
    # Header level 1.
    # @note Updated 2020-02-05.
    #
    # Alternatives: ==> (Homebrew) / ⇨  / →
    # """
    local c1 c2 nc pre str
    str="${1:?}"
    pre="$(_koopa_emoji) => "
    c1="$(_koopa_ansi_escape_code "blue")"
    c2="$(_koopa_ansi_escape_code "default-bold")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "\n${c1}${pre}${c2}${str}${nc}"
}

_koopa_h2() {  # {{{1
    # """
    # Header level 2.
    # @note Updated 2020-02-05.
    # """
    local c1 c2 nc pre str
    str="${1:?}"
    pre="$(_koopa_emoji) -> "
    c1="$(_koopa_ansi_escape_code "magenta")"
    c2="$(_koopa_ansi_escape_code "default")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "${c1}${pre}${c2}${str}${nc}"
}

_koopa_h3() {  # {{{1
    # """
    # Header level 3.
    # @note Updated 2020-02-05.
    # """
    local c1 c2 nc pre str
    str="${1:?}"
    pre="$(_koopa_emoji) -> "
    c1="$(_koopa_ansi_escape_code "default")"
    c2="$(_koopa_ansi_escape_code "default")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "${c1}${pre}${c2}${str}${nc}"
}

_koopa_h4() {  # {{{1
    _koopa_h3 "$@"
}

_koopa_h5() {  # {{{1
    _koopa_h3 "$@"
}

_koopa_h6() {  # {{{1
    _koopa_h3 "$@"
}

_koopa_h7() {  # {{{1
    _koopa_h3 "$@"
}

_koopa_info() {  # {{{1
    # """
    # General info.
    # @note Updated 2020-02-05.
    # """
    local c1 c2 nc pre str
    str="${1:?}"
    pre="$(_koopa_emoji) -- "
    c1="$(_koopa_ansi_escape_code "default")"
    c2="$(_koopa_ansi_escape_code "default")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "${c1}${pre}${c2}${str}${nc}"
}

_koopa_invalid_arg() {  # {{{1
    # """
    # Error on invalid argument.
    # @note Updated 2019-10-23.
    # """
    local arg
    arg="${1:?}"
    _koopa_stop "Invalid argument: '${arg}'."
}

_koopa_missing_arg() {  # {{{1
    # """
    # Error on a missing argument.
    # @note Updated 2019-10-23.
    # """
    _koopa_stop "Missing required argument."
}

_koopa_note() {  # {{{1
    # """
    # General note.
    # @note Updated 2020-02-05.
    # """
    local c1 c2 nc pre str
    str="${1:?}"
    pre="$(_koopa_emoji) ** "
    c1="$(_koopa_ansi_escape_code "yellow")"
    c2="$(_koopa_ansi_escape_code "default")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "${c1}${pre}${c2}${str}${nc}"
}

_koopa_status_fail() {  # {{{1
    # """
    # Status FAIL.
    # @note Updated 2020-02-04.
    # """
    local c1 nc pre str
    pre="      FAIL"
    str="${1:?}"
    c1="$(_koopa_ansi_escape_code "red-bold")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    >&2 echo -e "${c1}${pre}${nc} | ${str}"
}

_koopa_status_note() {  # {{{1
    # """
    # Status NOTE.
    # @note Updated 2020-02-04.
    # """
    local c1 nc pre str
    pre="      NOTE"
    str="${1:?}"
    c1="$(_koopa_ansi_escape_code "magenta")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    >&2 echo -e "${c1}${pre}${nc} | ${str}"
}

_koopa_status_ok() {  # {{{1
    # """
    # Status OK.
    # @note Updated 2020-02-04.
    # """
    local c1 nc pre str
    pre="        OK"
    str="${1:?}"
    c1="$(_koopa_ansi_escape_code "green")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "${c1}${pre}${nc} | ${str}"
}

_koopa_stop() {  # {{{1
    # """
    # Stop with an error message, and exit.
    # @note Updated 2020-02-11.
    # """
    local c1 c2 nc pre str
    str="ERROR: ${1:?}"
    pre="$(_koopa_emoji) !! "
    c1="$(_koopa_ansi_escape_code "red")"
    c2="$(_koopa_ansi_escape_code "red-bold")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    >&2 echo -e "${c1}${pre}${c2}${str}${nc}"
    exit 1
}

_koopa_success() {  # {{{1
    # """
    # Success message.
    # @note Updated 2020-02-05.
    # """
    local c1 c2 nc pre str
    str="${1:?}"
    pre="$(_koopa_emoji) OK "
    c1="$(_koopa_ansi_escape_code "green")"
    c2="$(_koopa_ansi_escape_code "green-bold")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    echo -e "${c1}${pre}${c2}${str}${nc}"
}

_koopa_warning() {  # {{{1
    # """
    # Warning message.
    # @note Updated 2020-02-11.
    # """
    local c1 c2 nc pre str
    str="WARNING: ${1:?}"
    pre="$(_koopa_emoji) !! "
    c1="$(_koopa_ansi_escape_code "yellow")"
    c2="$(_koopa_ansi_escape_code "default-bold")"
    nc="$(_koopa_ansi_escape_code "nocolor")"
    >&2 echo -e "${c1}${pre}${c2}${str}${nc}"
}

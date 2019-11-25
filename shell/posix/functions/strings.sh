#!/bin/sh
# shellcheck disable=SC2039

_koopa_gsub() {                                                           # {{{3
    # """
    # Global substitution.
    # Updated 2019-10-09.
    # """
    echo "$1" | sed -E "s/${2}/${3}/g"
}

_koopa_minor_version() {                                                  # {{{3
    # """
    # Get the major program version.
    # Updated 2019-09-23.
    # """
    echo "$1" | cut -d '.' -f 1-2
}

_koopa_strip_left() {                                                     # {{{3
    # """
    # Strip pattern from left side (start) of string.
    # Updated 2019-09-22.
    #
    # Usage: _koopa_lstrip "string" "pattern"
    #
    # Example: _koopa_lstrip "The Quick Brown Fox" "The "
    # """
    printf '%s\n' "${1##$2}"
}

_koopa_strip_right() {                                                    # {{{3
    # """
    # Strip pattern from right side (end) of string.
    # Updated 2019-09-22.
    #
    # Usage: _koopa_rstrip "string" "pattern"
    #
    # Example: _koopa_rstrip "The Quick Brown Fox" " Fox"
    # """
    printf '%s\n' "${1%%$2}"
}

_koopa_strip_trailing_slash() {                                           # {{{3
    # """
    # Strip trailing slash in file path string.
    # Updated 2019-09-24.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    # """
    _koopa_strip_right "$1" "/"
}

_koopa_sub() {                                                            # {{{3
    # """
    # Substitution.
    # Updated 2019-10-09.
    # See also: _koopa_gsub (for global matching).
    # """
    echo "$1" | sed -E "s/${2}/${3}/"
}

_koopa_trim_ws() {                                                        # {{{3
    # """
    # Trim leading and trailing white-space from string.
    # Updated 2019-09-22.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # Usage: _koopa_trim_ws "   example   string    "
    #
    # Example: _koopa_trim_ws "    Hello,  World    "
    # """
    trim="${1#${1%%[![:space:]]*}}"
    trim="${trim%${trim##*[![:space:]]}}"
    printf '%s\n' "$trim"
}

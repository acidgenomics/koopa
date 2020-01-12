#!/bin/sh
# shellcheck disable=SC2039

_koopa_gsub() {                                                           # {{{1
    # """
    # Global substitution.
    # Updated 2020-01-12.
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    local replacement
    replacement="${3:?}"
    echo "$string" | sed -E "s/${pattern}/${replacement}/g"
}

_koopa_major_version() {                                                  # {{{1
    # """
    # Get the major program version.
    # Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1
}

_koopa_minor_version() {                                                  # {{{1
    # """
    # Get the major program version.
    # Updated 2020-01-12.
    # """
    local version
    version="${1:?}"
    echo "$version" | cut -d '.' -f 1-2
}

_koopa_strip_left() {                                                     # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # Updated 2019-09-22.
    #
    # Usage: _koopa_strip_left "string" "pattern"
    #
    # Example: _koopa_strip_left "The Quick Brown Fox" "The "
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    printf '%s\n' "${string##$pattern}"
}

_koopa_strip_right() {                                                    # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # Updated 2020-01-12.
    #
    # Usage: _koopa_strip_right "string" "pattern"
    #
    # Example: _koopa_strip_right "The Quick Brown Fox" " Fox"
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    printf '%s\n' "${string%%$pattern}"
}

_koopa_strip_trailing_slash() {                                           # {{{1
    # """
    # Strip trailing slash in file path string.
    # Updated 2020-01-12.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    # """
    local file
    file="${1:?}"
    _koopa_strip_right "$file" "/"
}

_koopa_sub() {                                                            # {{{1
    # """
    # Substitution.
    # Updated 2020-01-12.
    # See also: _koopa_gsub (for global matching).
    # """
    local string
    string="${1:?}"
    local pattern
    pattern="${2:?}"
    local replacement
    replacement="${3:?}"
    echo "$string" | sed -E "s/${pattern}/${replacement}/"
}

_koopa_trim_ws() {                                                        # {{{1
    # """
    # Trim leading and trailing white-space from string.
    # Updated 2020-01-12.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # Usage: _koopa_trim_ws "   example   string    "
    #
    # Example: _koopa_trim_ws "    Hello,  World    "
    # """
    local string
    string="${1:?}"
    string="${string#${string%%[![:space:]]*}}"
    string="${string%${string##*[![:space:]]}}"
    printf '%s\n' "$string"
}

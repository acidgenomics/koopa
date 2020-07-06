#!/bin/sh

_koopa_macos_version() { # {{{1
    # """
    # macOS version.
    # @note Updated 2020-07-05.
    # """
    # shellcheck disable=SC2039
    local x
    _koopa_is_macos || return 1
    x="$(sw_vers -productVersion)"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_major_version() { # {{{1
    # """
    # Program 'MAJOR' version.
    # @note Updated 2020-07-04.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    # shellcheck disable=SC2039
    local version x
    for version in "$@"
    do
        x="$(_koopa_print "$version" | cut -d '.' -f 1)"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2020-07-04.
    # """
    # shellcheck disable=SC2039
    local version x
    for version in "$@"
    do
        x="$(_koopa_print "$version" | cut -d '.' -f 1-2)"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_patch_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2020-07-04.
    # """
    # shellcheck disable=SC2039
    local version x
    for version in "$@"
    do
        x="$(_koopa_print "$version" | cut -d '.' -f 1-3)"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_ruby_api_version() { # {{{1
    # """
    # Ruby API version.
    # @note Updated 2020-07-05.
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    # shellcheck disable=SC2039
    local x
    _koopa_is_installed ruby || return 1
    x="$(ruby -e 'print Gem.ruby_api_version')"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

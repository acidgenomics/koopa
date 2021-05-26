#!/bin/sh

_koopa_macos_version() { # {{{1
    # """
    # macOS version.
    # @note Updated 2020-07-05.
    # """
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
    # @note Updated 2021-05-26.
    #
    # This function captures 'MAJOR' only, removing 'MINOR.PATCH', etc.
    # """
    local cut version x
    cut='cut'
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | "$cut" -d '.' -f 1 \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR' version.
    # @note Updated 2021-05-26.
    # """
    local cut version x
    cut='cut'
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | "$cut" -d '.' -f '1-2' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_major_minor_patch_version() { # {{{1
    # """
    # Program 'MAJOR.MINOR.PATCH' version.
    # @note Updated 2021-05-26.
    # """
    local cut version x
    cut='cut'
    for version in "$@"
    do
        x="$( \
            _koopa_print "$version" \
            | "$cut" -d '.' -f '1-3' \
        )"
        [ -n "$x" ] || return 1
        _koopa_print "$x"
    done
    return 0
}

_koopa_ruby_api_version() { # {{{1
    # """
    # Ruby API version.
    # @note Updated 2021-05-24.
    #
    # Used by Homebrew Ruby for default gem installation path.
    # See 'brew info ruby' for details.
    # """
    local x
    _koopa_is_installed 'ruby' || return 1
    x="$(ruby -e 'print Gem.ruby_api_version')"
    [ -n "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

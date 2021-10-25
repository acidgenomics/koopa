#!/bin/sh

# FIXME Harden this as bash variants instead.
# FIXME Consider reworking this to support ripgrep.
# FIXME Rename this as grep in our Bash library.

__koopa_str_match() { # {{{1
    # """
    # Does the input match a string?
    # @note Updated 2021-05-26.
    #
    # Modes:
    # * -E, --extended-regexp
    # * -F, --fixed strings
    # * -G, --basic-regexp
    # * -P, --perl-regexp
    #
    # Perl-compatible regular expressions (PCREs) support negative
    # lookaheads, which are often very useful. However, Perl regex isn't enabled
    # by default for all installations of grep.
    #
    # Usage of '-q' flag can cause an exit trap in 'set -e' mode.
    # Redirecting output to '/dev/null' works more reliably.
    #
    # @seealso
    # - https://bugzilla.redhat.com/show_bug.cgi?id=1589997
    # - https://unix.stackexchange.com/questions/233987
    # """
    local OPTIND grep flag pattern string
    [ "$#" -gt 0 ] || return 1
    grep='grep'
    OPTIND=1
    while getopts 'EFP' opt
    do
        case "$opt" in
            'E')
                flag='-E'
                ;;
            'F')
                flag='-F'
                ;;
            'P')
                flag='-P'
                ;;
            \?)
                koopa::invalid_arg "$opt"
                ;;
        esac
    done
    shift "$((OPTIND-1))"
    if [ "$#" -eq 2 ]
    then
        # Standard input.
        # Note that we're allowing empty string input here.
        string="${1:-}"
        pattern="${2:?}"
    elif [ "$#" -eq 1 ]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        # Handle string with line breaks '\n'.
        # shellcheck disable=SC3045
        read -r -d '' string
    else
        return 1
    fi
    _koopa_print "$string" \
        | "$grep" "$flag" -q "$pattern" >/dev/null
}

_koopa_str_match_fixed() { # {{{1
    # """
    # Does the input match a fixed string?
    # @note Updated 2020-07-24.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_str_match -F "$@"
}

# FIXME Should we take this out?
# FIXME Consider reworking as pcregrep?
_koopa_str_match_perl() { # {{{
    # """
    # Does the input match a Perl-compatible regulare expression (PCRE)?
    # @note Updated 2020-07-24.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_str_match -P "$@"
}

_koopa_str_match_regex() { # {{{1
    # """
    # Does the input match a regular expression?
    # @note Updated 2020-07-24.
    # """
    [ "$#" -gt 0 ] || return 1
    __koopa_str_match -E "$@"
}




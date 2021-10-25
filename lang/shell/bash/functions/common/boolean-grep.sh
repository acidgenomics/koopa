#!/usr/bin/env bash

# FIXME We may need a koopa::file_match_perl function to replace pcregrep.
# FIXME Can we make an internal 'koopa:::file_match' variant like our 'str' one?

# FIXME Rename this?
# FIXME Rework our stdin approach? Use read?
# FIXME Require explicit arguments here, don't allow positional.
# FIXME Rename this to include fixed at the end.
koopa::file_match() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2021-10-25.
    #
    # @examples
    # koopa::file_match_fixed 'FILE' 'PATTERN'
    #
    # stdin support:
    # echo 'FILE' | koopa::file_match_fixed - 'PATTERN'
    # """
    local file grep pattern
    koopa::assert_has_args "$#"
    if [[ "$#" -eq 2 ]]
    then
        # Standard input.
        file="${1:?}"
        pattern="${2:?}"
    elif [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r file
    else
        return 1
    fi
    [[ -f "$file" ]] || return 1
    # FIXME Rework using 'koopa::grep'.
    grep="$(koopa::locate_grep)"
    "$grep" -Fq "$pattern" "$file" >/dev/null
}

# FIXME Rename this?
# FIXME Rework our stdin approach? Use read?
# FIXME Require explicit arguments here, don't allow positional.
koopa::file_match_regex() { # {{{1
    # """
    # Is a string defined in a file?
    # @note Updated 2021-10-25.
    #
    # @examples
    # koopa::file_match_regex 'FILE' '^PATTERN.+$'
    #
    # stdin support:
    # echo 'FILE' | koopa::file_match_regex - '^PATTERN.+$'
    # """
    local file grep pattern
    koopa::assert_has_args "$#"
    if [[ "$#" -eq 2 ]]
    then
        # Standard input.
        file="${1:?}"
        pattern="${2:?}"
    elif [[ "$#" -eq 1 ]]
    then
        # Piped input using stdin.
        pattern="${1:?}"
        shift 1
        read -r file
    else
        return 1
    fi
    [[ -f "$file" ]] || return 1
    # FIXME Rework using 'koopa::grep'.
    grep="$(koopa::locate_grep)"
    "$grep" -Eq "$pattern" "$file" >/dev/null
}


# FIXME Harden this as bash variants instead.
# FIXME Consider reworking this to support ripgrep.
# FIXME Rename this as grep in our Bash library.

koopa:::str_match() { # {{{1
    # """
    # Does the input match a string?
    # @note Updated 2021-10-25.
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

koopa::str_match_fixed() { # {{{1
    # """
    # Does the input match a fixed string?
    # @note Updated 2020-07-24.
    # """
    koopa:::str_match -F "$@"
}

# FIXME Should we take this out?
# FIXME Consider reworking as pcregrep?
koopa::str_match_perl() { # {{{
    # """
    # Does the input match a Perl-compatible regulare expression (PCRE)?
    # @note Updated 2020-07-24.
    # """
    koopa:::str_match -P "$@"
}

koopa::str_match_regex() { # {{{1
    # """
    # Does the input match a regular expression?
    # @note Updated 2020-07-24.
    # """
    koopa:::str_match -E "$@"
}

#!/usr/bin/env bash

koopa::camel_case_simple() { # {{{1
    # """
    # Simple camel case function.
    # @note Updated 2022-02-17.
    #
    # @seealso
    # - syntactic R package.
    # - https://stackoverflow.com/questions/34420091/
    #
    # @usage koopa::camel_case_simple STRING...
    #
    # @examples
    # > koopa::camel_case_simple 'hello world'
    # # helloWorld
    # """
    local app str
    koopa::assert_has_args "$#"
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    for str in "$@"
    do
        [[ -n "$str" ]] || return 1
        str="$( \
            koopa::print "$str" \
                | "${app[sed]}" \
                    --regexp-extended \
                    's/([ -_])([a-z])/\U\2/g' \
        )"
        [[ -n "$str" ]] || return 1
        koopa::print "$str"
    done
    return 0
}

koopa::capitalize() { # {{{1
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2022-02-17.
    #
    # @seealso
    # - https://stackoverflow.com/a/12487465
    #
    # @usage koopa::capitalize STRING...
    #
    # @examples
    # > koopa::capitalize 'hello world' 'foo bar'
    # # 'Hello world' 'Foo bar'
    # """
    local app str
    koopa::assert_has_args "$#"
    declare -A app=(
        [tr]="$(koopa::locate_tr)"
    )
    for str in "$@"
    do
        str="$("${app[tr]}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa::print "$str"
    done
    return 0
}

koopa::gsub() { # {{{1
    # """
    # Global substitution.
    # @note Updated 2022-02-17.
    #
    # @usage koopa::gsub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa::gsub --pattern='a' --replacement='' 'aabb' 'aacc'
    # # bb
    # # cc
    # """
    koopa::sub --global "$@"
}

koopa::kebab_case_simple() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2022-02-17.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa::kebab_case_simple 'hello world'
    # # hello-world
    #
    # > koopa::kebab_case_simple 'bcbio-nextgen.py'
    # # bcbio-nextgen-py
    # """
    local str
    koopa::assert_has_args "$#"
    for str in "$@"
    do
        str="$(\
            koopa::gsub \
                --pattern='[^-A-Za-z0-9]' \
                --replacement='-' \
                "$str" \
        )"
        str="$(koopa::lowercase "$str")"
        koopa::print "$str"
    done
    return 0
}

koopa::lowercase() { # {{{1
    # """
    # Transform string to lowercase.
    # @note Updated 2022-02-17.
    #
    # awk alternative:
    # > koopa::print "$str" | "${app[awk]}" '{print tolower($0)}'
    #
    # @examples
    # koopa::lowercase 'HELLO WORLD'
    # ## hello world
    #
    # @seealso
    # - https://stackoverflow.com/questions/2264428
    # """
    local app str
    koopa::assert_has_args "$#"
    declare -A app=(
        [tr]="$(koopa::locate_tr)"
    )
    for str in "$@"
    do
        koopa::print "$str" \
            | "${app[tr]}" '[:upper:]' '[:lower:]'
    done
    return 0
}

koopa::paste() { # {{{1
    # """
    # Paste arguments into a string separated by delimiter.
    # @note Updated 2021-11-30.
    #
    # @seealso
    # - https://stackoverflow.com/a/57536163/3911732/
    # - https://stackoverflow.com/questions/13470413/
    # - https://stackoverflow.com/questions/1527049/
    #
    # @examples
    # > koopa::paste --sep=', ' 'aaa bbb' 'ccc ddd'
    # # aaa bbb, ccc ddd
    # """
    local IFS pos sep str
    sep=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--sep='*)
                sep="${1#*=}"
                shift 1
                ;;
            '--sep')
                sep="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    IFS=''
    str="${*/#/$sep}"
    str="${str:${#sep}}"
    koopa::print "$str"
    return 0
}

koopa::paste0() { # {{{1
    # """
    # Paste arguments to string without a delimiter.
    # @note Updated 2021-11-30.
    #
    # @examples
    # > koopa::paste0 'aaa' 'bbb'
    # # aaabbb
    # """
    koopa::paste --sep='' "$@"
}

koopa::snake_case_simple() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2022-02-23.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa::snake_case_simple 'hello world'
    # # hello_world
    #
    # > koopa::snake_case_simple 'bcbio-nextgen.py'
    # # bcbio_nextgen_py
    # """
    local str
    koopa::assert_has_args "$#"
    for str in "$@"
    do
        str="$( \
            koopa::gsub \
                --pattern='[^A-Za-z0-9_]' \
                --replacement='_' \
                "$str" \
        )"
        str="$(koopa::lowercase "$str")"
        koopa::print "$str"
    done
    return 0
}

koopa::strip_left() { # {{{1
    # """
    # Strip pattern from left side (start) of string.
    # @note Updated 2022-02-17.
    #
    # @usage koopa::strip_left --pattern=PATTERN STRING...
    #
    # @examples
    # > koopa::strip_left \
    # >     --pattern='The ' \
    # >     'The Quick Brown Fox' \
    # >     'The White Lady'
    # # Quick Brown Fox
    # # White Lady
    # """
    local dict pos str
    declare -A dict=(
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    for str in "$@"
    do
        printf '%s\n' "${str##"${dict[pattern]}"}"
    done
    return 0
}

koopa::strip_right() { # {{{1
    # """
    # Strip pattern from right side (end) of string.
    # @note Updated 2022-02-17.
    #
    # @usage koopa::strip_right --pattern=PATTERN STRING...
    #
    # @examples
    # > koopa::strip_right \
    # >     --pattern=' Fox' \
    # >     'The Quick Brown Fox' \
    # >     'Michael J. Fox'
    # # The Quick Brown
    # # Michael J.
    # """
    local dict pos str
    declare -A dict=(
        [pattern]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    for str in "$@"
    do
        printf '%s\n' "${str%%"${dict[pattern]}"}"
    done
    return 0
}

koopa::strip_trailing_slash() { # {{{1
    # """
    # Strip trailing slash in file path string.
    # @note Updated 2022-02-17.
    #
    # Alternate approach using sed:
    # > sed 's/\/$//' <<< "$1"
    #
    # @usage koopa::strip_trailing_slash STRING...
    #
    # @examples
    # > koopa::strip_trailing_slash './dir1/' './dir2/'
    # # ./dir1
    # # ./dir2
    # """
    koopa::assert_has_args "$#"
    koopa::strip_right --pattern='/' "$@"
    return 0
}

koopa::sub() { # {{{1
    # """
    # Single substitution.
    # @note Updated 2022-02-17.
    #
    # @usage koopa::sub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa::sub --pattern='a' --replacement='' 'aaa' 'aaa'
    # # aa
    # # aa
    # """
    local app dict pos str
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [global]=0
        [pattern]=''
        [replacement]=''
        [sed_tail]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict[pattern]="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict[pattern]="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict[replacement]="${1#*=}"
                shift 1
                ;;
            '--replacement')
                # Allowing empty string passthrough here.
                dict[replacement]="${2:-}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--global')
                dict[global]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa::assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    [[ "${dict[global]}" -eq 1 ]] && dict[sed_tail]='g'
    for str in "$@"
    do
        koopa::print "$str" \
            | "${app[sed]}" \
                --regexp-extended \
                "s|${dict[pattern]}|${dict[replacement]}|${dict[sed_tail]}"
    done
    return 0
}

koopa::to_string() { # {{{1
    # """
    # Paste arguments to a comma separated string.
    # @note Updated 2021-11-30.
    #
    # @examples
    # > koopa::to_string 'aaa' 'bbb'
    # # aaa, bbb
    # """
    koopa::assert_has_args "$#"
    koopa::paste0 --sep=', ' "$@"
    return 0
}

koopa::trim_ws() { # {{{1
    # """
    # Trim leading and trailing white-space from string.
    # @note Updated 2022-02-17.
    #
    # This is an alternative to sed, awk, perl and other tools. The function
    # works by finding all leading and trailing white-space and removing it from
    # the start and end of the string.
    #
    # We're allowing empty string input in this function.
    #
    # @examples
    # > koopa::trim_ws '  hello world  ' ' foo bar '
    # # hello world
    # # foo bar
    # """
    local str
    koopa::assert_has_args "$#"
    for str in "$@"
    do
        str="${str#"${str%%[![:space:]]*}"}"
        str="${str%"${str##*[![:space:]]}"}"
        koopa::print "$str"
    done
    return 0
}

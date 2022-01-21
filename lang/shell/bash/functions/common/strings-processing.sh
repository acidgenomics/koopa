#!/usr/bin/env bash

koopa::camel_case_simple() { # {{{1
    # """
    # Simple camel case function.
    # @note Updated 2022-01-20.
    #
    # @examples
    # koopa::camel_case_simple 'hello world'
    # ## helloWorld
    #
    # @seealso
    # https://stackoverflow.com/questions/34420091/
    # """
    local app string
    koopa::assert_has_args "$#"
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    for string in "$@"
    do
        koopa::print "$string" \
            | "${app[sed]}" -E 's/([ -_])([a-z])/\U\2/g'
    done
    return 0
}

koopa::capitalize() { # {{{1
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2021-11-30.
    #
    # @examples
    # koopa::capitalize 'hello world' 'foo bar'
    # ## 'Hello world' 'Foo bar'
    # @seealso
    # - https://stackoverflow.com/a/12487465
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
    # @note Updated 2022-01-21.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @examples
    # koopa::gsub 'a' '' 'aabb' 'aacc'
    # ## bb
    # ## cc
    # """
    local app dict string
    koopa::assert_has_args_eq "$#" 3
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
        [replacement]="${2:-}"
    )
    shift 2
    for string in "$@"
    do
        koopa::print "$string" \
            | "${app[sed]}" -E "s|${dict[pattern]}|${dict[replacement]}|g"
    done
    return 0
}

koopa::kebab_case_simple() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2022-01-20.
    #
    # @seealso
    # - Exported 'kebab-case' that uses R syntactic internally.
    #
    # @examples
    # koopa::kebab_case_simple 'hello world'
    # ## hello-world
    #
    # koopa::kebab_case_simple 'bcbio-nextgen.py'
    # ## bcbio-nextgen-py
    # """
    local string
    koopa::assert_has_args "$#"
    for string in "$@"
    do
        string="$(koopa::gsub '[^-A-Za-z0-9]' '-' "$string")"
        string="$(koopa::lowercase "$string")"
        koopa::print "$string"
    done
    return 0
}

koopa::lowercase() { # {{{1
    # """
    # Transform string to lowercase.
    # @note Updated 2022-01-20.
    #
    # awk alternative:
    # > koopa::print "$string" | "${app[awk]}" '{print tolower($0)}'
    #
    # @examples
    # koopa::lowercase 'HELLO WORLD'
    # ## hello world
    #
    # @seealso
    # - https://stackoverflow.com/questions/2264428
    # """
    local app string
    koopa::assert_has_args "$#"
    declare -A app=(
        [tr]="$(koopa::locate_tr)"
    )
    for string in "$@"
    do
        koopa::print "$string" \
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
    # @note Updated 2022-01-20.
    #
    # @seealso
    # - Exported 'snake-case' that uses R syntactic internally.
    #
    # @examples
    # koopa::snake_case_simple 'hello world'
    # ## hello_world
    #
    # koopa::snake_case_simple 'bcbio-nextgen.py'
    # ## bcbio_nextgen_py
    # """
    local string
    koopa::assert_has_args "$#"
    for string in "$@"
    do
        string="$(koopa::gsub '[^A-Za-z0-9_]' '_' "$string")"
        string="$(koopa::lowercase "$string")"
        koopa::print "$string"
    done
    return 0
}

koopa::sub() { # {{{1
    # """
    # Single substitution.
    # @note Updated 2022-01-21.
    #
    # Instead of using '|' in sed here, we can also escape '/'.
    #
    # @examples
    # koopa::sub 'a' '' 'aaa' 'aaa'
    # ## aa
    # ## aa
    # """
    local app dict string
    declare -A app=(
        [sed]="$(koopa::locate_sed)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
        [replacement]="${2:-}"
    )
    shift 2
    for string in "$@"
    do
        koopa::print "$string" \
            | "${app[sed]}" -E "s|${dict[pattern]}|${dict[replacement]}|"
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
    # @note Updated 2022-01-21.
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
    local string
    koopa::assert_has_args "$#"
    for string in "$@"
    do
        string="${string#"${string%%[![:space:]]*}"}"
        string="${string%"${string##*[![:space:]]}"}"
        koopa::print "$string"
    done
    return 0
}

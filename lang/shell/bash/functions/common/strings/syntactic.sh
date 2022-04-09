#!/usr/bin/env bash

koopa_camel_case_simple() { # {{{1
    # """
    # Simple camel case function.
    # @note Updated 2022-03-15.
    #
    # @seealso
    # - syntactic R package.
    # - https://stackoverflow.com/questions/34420091/
    #
    # @usage koopa_camel_case_simple STRING...
    #
    # @examples
    # > koopa_camel_case_simple 'hello world'
    # # helloWorld
    # """
    local app args str
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        [[ -n "$str" ]] || return 1
        str="$( \
            koopa_print "$str" \
                | "${app[sed]}" -E 's/([ -_])([a-z])/\U\2/g' \
        )"
        [[ -n "$str" ]] || return 1
        koopa_print "$str"
    done
    return 0
}

koopa_capitalize() { # {{{1
    # """
    # Capitalize the first letter (only) of a string.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - https://stackoverflow.com/a/12487465
    #
    # @usage koopa_capitalize STRING...
    #
    # @examples
    # > koopa_capitalize 'hello world' 'foo bar'
    # # 'Hello world' 'Foo bar'
    # """
    local app args str
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        str="$("${app[tr]}" '[:lower:]' '[:upper:]' <<< "${str:0:1}")${str:1}"
        koopa_print "$str"
    done
    return 0
}

koopa_kebab_case_simple() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa_kebab_case_simple 'hello world'
    # # hello-world
    #
    # > koopa_kebab_case_simple 'bcbio-nextgen.py'
    # # bcbio-nextgen-py
    # """
    local args str
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        str="$(\
            koopa_gsub \
                --pattern='[^-A-Za-z0-9]' \
                --replacement='-' \
                "$str" \
        )"
        str="$(koopa_lowercase "$str")"
        koopa_print "$str"
    done
    return 0
}

koopa_lowercase() { # {{{1
    # """
    # Transform string to lowercase.
    # @note Updated 2022-03-01.
    #
    # awk alternative:
    # > koopa_print "$str" | "${app[awk]}" '{print tolower($0)}'
    #
    # @seealso
    # - https://stackoverflow.com/questions/2264428
    #
    # @examples
    # > koopa_lowercase 'HELLO WORLD'
    # # hello world
    # """
    local app args str
    koopa_assert_has_args "$#"
    declare -A app=(
        [tr]="$(koopa_locate_tr)"
    )
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        koopa_print "$str" \
            | "${app[tr]}" '[:upper:]' '[:lower:]'
    done
    return 0
}

koopa_snake_case_simple() { # {{{1
    # """
    # Simple snake case function.
    # @note Updated 2022-03-01.
    #
    # @seealso
    # - syntactic R package.
    #
    # @examples
    # > koopa_snake_case_simple 'hello world'
    # # hello_world
    #
    # > koopa_snake_case_simple 'bcbio-nextgen.py'
    # # bcbio_nextgen_py
    # """
    local args str
    if [[ "$#" -eq 0 ]]
    then
        args=("$(</dev/stdin)")
    else
        args=("$@")
    fi
    for str in "${args[@]}"
    do
        str="$( \
            koopa_gsub \
                --pattern='[^A-Za-z0-9_]' \
                --replacement='_' \
                "$str" \
        )"
        str="$(koopa_lowercase "$str")"
        koopa_print "$str"
    done
    return 0
}

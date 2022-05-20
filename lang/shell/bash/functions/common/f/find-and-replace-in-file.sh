#!/usr/bin/env bash

koopa_find_and_replace_in_file() {
    # """
    # Find and replace inside files.
    # @note Updated 2022-04-22.
    #
    # Parameterized, supporting multiple files.
    #
    # This step requires GNU sed and won't work with BSD sed currently installed
    # by default on macOS.
    #
    # @seealso
    # - koopa_sub
    # - https://stackoverflow.com/questions/4247068/
    # - https://stackoverflow.com/questions/5720385/
    # - https://stackoverflow.com/questions/2922618/
    # - Use '-0' for multiline replacement
    #   https://stackoverflow.com/questions/1030787/
    # - https://unix.stackexchange.com/questions/334216/
    #
    # @usage
    # > koopa_find_and_replace_in_file \
    # >     [--fixed|--regex] \
    # >     --pattern=PATTERN \
    # >     --replacement=REPLACEMENT \
    # >     FILE...
    #
    # @examples
    # > koopa_find_and_replace_in_file \
    # >     --fixed \
    # >     --pattern='XXX' \
    # >     --replacement='YYY' \
    # >     'file1' 'file2' 'file3'
    # """
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    declare -A dict=(
        [pattern]=''
        [regex]=0
        [replacement]=''
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
            '--fixed')
                dict[regex]=0
                shift 1
                ;;
            '--regex')
                dict[regex]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict[pattern]}"
    [[ "${#pos[@]}" -eq 0 ]] && pos=("$(</dev/stdin)")
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    if [[ "${dict[regex]}" -eq 1 ]]
    then
        dict[expr]="s/${dict[pattern]}/${dict[replacement]}/g"
    else
        dict[expr]=" \
            \$pattern = quotemeta '${dict[pattern]}'; \
            \$replacement = '${dict[replacement]}'; \
            s/\$pattern/\$replacement/g; \
        "
    fi
    # Consider using '-0' here for multi-line matching. This makes regular
    # expression matching with line endings more difficult, so disabled.
    "${app[perl]}" -i -p -e "${dict[expr]}" "$@"
    return 0
}

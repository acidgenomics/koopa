#!/usr/bin/env bash

koopa_gsub() { # {{{1
    # """
    # Global substitution.
    # @note Updated 2022-02-17.
    #
    # @usage koopa_gsub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa_gsub --pattern='a' --replacement='' 'aabb' 'aacc'
    # # bb
    # # cc
    # """
    koopa_sub --global "$@"
}

koopa_sub() { # {{{1
    # """
    # Single substitution.
    # @note Updated 2022-04-21.
    #
    # @usage koopa_sub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa_sub --pattern='a' --replacement='' 'aabb' 'bbaa'
    # # abb
    # # bba
    # """
    local app dict pos
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    declare -A dict=(
        [global]=0
        [pattern]=''
        [perl_tail]=''
        [regex]=1
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
            '--global')
                dict[global]=1
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
    [[ "${dict[regex]}" -eq 0 ]] && dict[pattern]="\\Q${dict[pattern]}\\E"
    [[ "${dict[global]}" -eq 1 ]] && dict[perl_tail]='g'
    dict[expr]="s/${dict[pattern]}/${dict[replacement]}/${dict[perl_tail]}"
    koopa_print "$@" \
        | "${app[perl]}" -p -e "${dict[expr]}"
    return 0
}

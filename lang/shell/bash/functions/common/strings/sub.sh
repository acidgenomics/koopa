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
    # @note Updated 2022-03-15.
    #
    # @usage koopa_sub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa_sub --pattern='a' --replacement='' 'aaa' 'aaa'
    # # aa
    # # aa
    # """
    local app dict pos str
    declare -A app=(
        [sed]="$(koopa_locate_sed)"
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
    [[ "${dict[global]}" -eq 1 ]] && dict[sed_tail]='g'
    for str in "${pos[@]}"
    do
        # Ensure '|' are escaped. Need to use '//' here for global escaping
        # of multiple vertical pipes.
        dict[pattern]="${dict[pattern]//|/\\|}"
        dict[replacement]="${dict[replacement]//|/\\|}"
        koopa_print "$str" \
            | "${app[sed]}" -E \
                "s|${dict[pattern]}|${dict[replacement]}|${dict[sed_tail]}"
    done
    return 0
}

#!/usr/bin/env bash

koopa_sub() {
    # """
    # Single substitution.
    # @note Updated 2022-04-21.
    #
    # @seealso
    # - https://perldoc.perl.org/functions/quotemeta
    #
    # @usage koopa_sub --pattern=PATTERN --replacement=REPLACEMENT STRING...
    #
    # @examples
    # > koopa_sub --pattern='a' --replacement='' 'aabb' 'bbaa'
    # # abb
    # # bba
    #
    # # koopa_sub --pattern='/' --replacement='|' '/\|/\|'
    # # |\|/\|
    # """
    local app dict pos
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    declare -A dict=(
        [global]=0
        [pattern]=''
        [perl_tail]=''
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
    [[ "${dict[global]}" -eq 1 ]] && dict[perl_tail]='g'
    if [[ "${dict[regex]}" -eq 1 ]]
    then
        dict[expr]="s/${dict[pattern]}/${dict[replacement]}/${dict[perl_tail]}"
    else
        dict[expr]=" \
            \$pattern = quotemeta '${dict[pattern]}'; \
            \$replacement = '${dict[replacement]}'; \
            s/\$pattern/\$replacement/${dict[perl_tail]}; \
        "
    fi
    # Using 'printf' instead of 'koopa_print' here avoids issues with Perl
    # matching line break characters.
    printf '%s' "$@" | "${app[perl]}" -p -e "${dict[expr]}"
    return 0
}

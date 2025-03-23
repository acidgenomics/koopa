#!/usr/bin/env bash

koopa_sub() {
    # """
    # Single substitution.
    # @note Updated 2023-10-10.
    #
    # Using 'printf' instead of 'koopa_print' here avoids issues with Perl
    # matching line break characters. Additionally, using 'LANG=C' helps avoid
    # locale issues on machines with non-standard configurations, such as the
    # current biocontainers Docker image.
    #
    # @seealso
    # - https://perldoc.perl.org/functions/quotemeta
    # - https://perldoc.perl.org/perlop.html
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
    local -A app bool dict
    local -a out pos
    local str
    app['perl']="$(koopa_locate_perl --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['global']=0
    bool['regex']=0
    dict['pattern']=''
    dict['replace']=''
    dict['tail']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--pattern='*)
                dict['pattern']="${1#*=}"
                shift 1
                ;;
            '--pattern')
                dict['pattern']="${2:?}"
                shift 2
                ;;
            '--replacement='*)
                dict['replace']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                dict['replace']="${2:-}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--fixed')
                bool['regex']=0
                shift 1
                ;;
            '--global')
                bool['global']=1
                shift 1
                ;;
            '--regex')
                bool['regex']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '--'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    [[ "${bool['global']}" -eq 1 ]] && dict['tail']='g'
    if [[ "${bool['regex']}" -eq 1 ]]
    then
        dict['pattern']="${dict['pattern']//\//\\\/}"
        dict['replace']="${dict['replace']//\//\\\/}"
        dict['expr']="s/${dict['pattern']}/${dict['replace']}/${dict['tail']}"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replace']}'; \
            s/\$pattern/\$replacement/${dict['tail']}; \
        "
    fi
    for str in "$@"
    do
        if [[ -z "$str" ]]
        then
            out+=("$str")
            continue
        fi
        out+=(
            "$( \
                printf '%s' "$str" \
                | LANG=C "${app['perl']}" -p -e "${dict['expr']}" \
            )"
        )
    done
    koopa_print "${out[@]}"
    return 0
}

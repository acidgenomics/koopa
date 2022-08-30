#!/usr/bin/env bash

koopa_find_and_replace_in_file() {
    # """
    # Find and replace inside files.
    # @note Updated 2022-08-30.
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
    local app dict flags perl_cmd pos
    koopa_assert_has_args "$#"
    declare -A app
    app['perl']="$(koopa_locate_perl --allow-missing)"
    [[ ! -x "${app['perl']}" ]] && app['perl']='/usr/bin/perl'
    [[ -x "${app['perl']}" ]] || return 1
    declare -A dict=(
        ['multiline']=0
        ['pattern']=''
        ['regex']=0
        ['replacement']=''
        ['sudo']=0
    )
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
                dict['replacement']="${1#*=}"
                shift 1
                ;;
            '--replacement')
                # Allowing empty string passthrough here.
                dict['replacement']="${2:-}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--fixed')
                dict['regex']=0
                shift 1
                ;;
            '--multiline')
                dict['multiline']=1
                shift 1
                ;;
            '--regex')
                dict['regex']=1
                shift 1
                ;;
            '--sudo')
                dict['sudo']=1
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
    koopa_assert_is_set '--pattern' "${dict['pattern']}"
    if [[ "${#pos[@]}" -eq 0 ]]
    then
        readarray -t pos <<< "$(</dev/stdin)"
    fi
    set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    if [[ "${dict['regex']}" -eq 1 ]]
    then
        # FIXME Need to improve the regex escaping here.
        dict['expr']="s|${dict['pattern']}|${dict['replacement']}|g"
    else
        dict['expr']=" \
            \$pattern = quotemeta '${dict['pattern']}'; \
            \$replacement = '${dict['replacement']}'; \
            s/\$pattern/\$replacement/g; \
        "
    fi
    flags=('-i' '-p')
    # Multi-line matching is disabled by default, because it makes regular
    # expression matching end of line break.
    [[ "${dict['multiline']}" -eq 1 ]] && flags+=('-0')
    if [[ "${dict['sudo']}" -eq 1 ]]
    then
        koopa_assert_is_admin
        app['sudo']="$(koopa_locate_sudo)"
        [[ -x "${app['sudo']}" ]] || return 1
        perl_cmd+=("${app['sudo']}" "${app['perl']}")
    else
        perl_cmd=("${app['perl']}")
    fi
    "${perl_cmd[@]}" "${flags[@]}" -e "${dict['expr']}" "$@"
    return 0
}

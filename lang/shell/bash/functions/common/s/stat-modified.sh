#!/usr/bin/env bash

koopa_stat_modified() {
    # """
    # Get file modification time.
    # @note Updated 2023-03-26.
    #
    # @seealso
    # - Convert seconds since Epoch into a useful format.
    #   https://www.gnu.org/software/coreutils/manual/html_node/
    #     Examples-of-date.html
    #
    # @examples
    # > koopa_stat_modified --format='%Y-%m-%d' '/tmp' "${HOME:?}"
    # # 2023-02-09
    # # 2023-03-26
    # """
    local app dict pos timestamp timestamps
    koopa_assert_has_args "$#"
    declare -A app dict
    app['date']="$(koopa_locate_date)"
    app['stat']="$(koopa_locate_stat)"
    [[ -x "${app['date']}" ]] || return 1
    [[ -x "${app['stat']}" ]] || return 1
    dict['format']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--format='*)
                dict['format']="${1#*=}"
                shift 1
                ;;
            '--format')
                dict['format']="${2:?}"
                shift 2
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
    koopa_assert_is_set '--format' "${dict['format']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_existing "$@"
    readarray -t timestamps <<< "$( \
        "${app['stat']}" --format='%Y' "$@" \
    )"
    for timestamp in "${timestamps[@]}"
    do
        local string
        string="$( \
            "${app['date']}" -d "@${timestamp}" +"${dict['format']}" \
        )"
        [[ -n "$string" ]] || return 1
        koopa_print "$string"
    done
    return 0
}

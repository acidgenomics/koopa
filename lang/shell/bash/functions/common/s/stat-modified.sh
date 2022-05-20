#!/usr/bin/env bash

koopa_stat_modified() {
    # """
    # Get file modification time.
    # @note Updated 2021-11-16.
    #
    # @seealso
    # - Convert seconds since Epoch into a useful format.
    #   https://www.gnu.org/software/coreutils/manual/html_node/
    #     Examples-of-date.html
    #
    # @examples
    # > koopa_stat_modified '%Y-%m-%d' '/tmp'
    # # 2021-10-17
    # """
    local app dict timestamp timestamps x
    koopa_assert_has_args_ge "$#" 2
    declare -A app=(
        [date]="$(koopa_locate_date)"
    )
    declare -A dict=(
        [format]="${1:?}"
    )
    shift 1
    readarray -t timestamps <<< "$(koopa_stat '%Y' "$@")"
    for timestamp in "${timestamps[@]}"
    do
        x="$("${app[date]}" -d "@${timestamp}" +"${dict[format]}")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

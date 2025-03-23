#!/usr/bin/env bash

koopa_stack_trace() {
    # """
    # Stack trace.
    # @note Updated 2024-03-04.
    #
    # @seealso
    # - https://github.com/TritonDataCenter/sdc-headnode/blob/master/
    #     buildtools/lib/error_handler.sh
    # - https://news.ycombinator.com/item?id=39568728
    # """
    local cnt i
    koopa_assert_has_no_args "$#"
    set +o xtrace
    printf '\nStack trace:\n'
    (( cnt = ${#FUNCNAME[@]} ))
    (( i = 0 ))
    while (( i < cnt ))
    do
        local line
        printf '[%3d] %s\n' "${i}" "${FUNCNAME[i]}"
        if (( i > 0 ))
        then
            line="${BASH_LINENO[$((i - 1))]}"
        else
            line="${LINENO}"
        fi
        printf '      file "%s" line %d\n' "${BASH_SOURCE[i]}" "${line}"
        (( i++ ))
    done
    return 0
}

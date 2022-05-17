#!/usr/bin/env bash

koopa_script_name() {
    # """
    # Get the calling script name.
    # @note Updated 2022-02-09.
    #
    # Note that we're using 'caller' approach, which is Bash-specific.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [head]="$(koopa_locate_head)"
    )
    declare -A dict
    dict[file]="$( \
        caller \
        | "${app[head]}" -n 1 \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    dict[bn]="$(koopa_basename "${dict[file]}")"
    [[ -n "${dict[bn]}" ]] || return 0
    koopa_print "${dict[bn]}"
    return 0
}

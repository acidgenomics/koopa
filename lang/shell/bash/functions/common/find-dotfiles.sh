#!/usr/bin/env bash

koopa_find_dotfiles() {
    # """
    # Find dotfiles by type.
    # @note Updated 2022-02-17.
    #
    # This is used internally by 'koopa_list_dotfiles' script.
    #
    # 1. Type ('f' file; or 'd' directory).
    # 2. Header message (e.g. 'Files')
    # """
    local app dict
    koopa_assert_has_args_eq "$#" 2
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [basename]="$(koopa_locate_basename)"
        [xargs]="$(koopa_locate_xargs)"
    )
    declare -A dict=(
        [type]="${1:?}"
        [header]="${2:?}"
    )
    # shellcheck disable=SC2016
    dict[str]="$( \
        koopa_find \
            --max-depth=1 \
            --pattern='.*' \
            --prefix="${HOME:?}" \
            --print0 \
            --sort \
            --type="${dict[type]}" \
        | "${app[xargs]}" -0 -n 1 "${app[basename]}" \
        | "${app[awk]}" '{print "    -",$0}' \
    )"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_h2 "${dict[header]}:"
    koopa_print "${dict[str]}"
    return 0
}

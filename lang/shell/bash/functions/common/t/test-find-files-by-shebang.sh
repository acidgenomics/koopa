#!/usr/bin/env bash

koopa_test_find_files_by_shebang() {
    # """
    # Find relevant test files by shebang.
    # @note Updated 2022-01-31.
    # """
    local all_files app dict file shebang_files
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [tr]="$(koopa_locate_tr)"
    )
    declare -A dict=(
        [pattern]="${1:?}"
    )
    readarray -t all_files <<< "$(koopa_test_find_files)"
    shebang_files=()
    for file in "${all_files[@]}"
    do
        local shebang
        [[ -s "$file" ]] || continue
        # Avoid 'command substitution: ignored null byte in input' warning.
        shebang="$( \
            "${app[tr]}" --delete '\0' < "$file" \
                | "${app[head]}" -n 1 \
        )"
        [[ -n "$shebang" ]] || continue
        if koopa_str_detect_regex \
            --string="$shebang" \
            --pattern="${dict[pattern]}"
        then
            shebang_files+=("$file")
        fi
    done
    koopa_print "${shebang_files[@]}"
    return 0
}

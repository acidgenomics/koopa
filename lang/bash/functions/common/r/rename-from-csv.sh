#!/usr/bin/env bash

koopa_rename_from_csv() {
    # """
    # Rename files from CSV template.
    # @note Updated 2022-02-17.
    #
    # @usage koopa_rename_from_csv CSV_FILE
    # """
    local file line
    koopa_assert_has_args "$#"
    file="${1:?}"
    koopa_assert_is_file_type --ext='csv' "$file"
    while read -r line
    do
        local from to
        from="${line%,*}"
        to="${line#*,}"
        koopa_mv "$from" "$to"
    done < "$file"
    return 0
}

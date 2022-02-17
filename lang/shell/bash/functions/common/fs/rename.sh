#!/usr/bin/env bash

koopa_rename_from_csv() { # {{{1
    # """
    # Rename files from CSV template.
    # @note Updated 2022-02-16.
    # """
    local file line
    koopa::assert_has_args "$#"
    file="${1:?}"
    koopa::assert_is_file_type "$file" 'csv'
    while read -r line
    do
        local from to
        from="${line%,*}"
        to="${line#*,}"
        koopa::mv "$from" "$to"
    done < "$file"
    return 0
}

koopa::rename_lowercase() { # {{{1
    # """
    # Rename files to lowercase.
    # @note Updated 2022-02-16.
    # """
    local app dict
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [rename]="$(koopa::locate_rename)"
        [sort]="$(koopa::locate_sort)"
        [xargs]="$(koopa::locate_xargs)"
    )
    declare -A dict=(
        [pattern]='y/A-Z/a-z/'
        [recursive]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--recursive')
                dict[recursive]=1
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "${dict[recursive]}" -eq 1 ]]
    then
        koopa::assert_has_args_le "$#" 1
        dict[prefix]="${1:-.}"
        # Rename files.
        # FIXME Rework using 'koopa::find'.
        "${app[find]}" "${dict[prefix]}" \
            -mindepth 1 \
            -type 'f' \
            -name '*[A-Z]*' \
            -not -name '.*' \
            -print0 \
            | "${app[sort]}" --zero-terminated \
            | "${app[xargs]}" --null -I {} \
                "${app[rename]}" \
                    --force \
                    --verbose \
                    "${dict[pattern]}" \
                    {}
        # Rename directories.
        # FIXME Rework using 'koopa::find'.
        "${app[find]}" "${dict[prefix]}" \
            -mindepth 1 \
            -type 'd' \
            -name '*[A-Z]*' \
            -not -name '.*' \
            -print0 \
            | "${app[sort]}" --reverse --zero-terminated \
            | "${app[xargs]}" --null -I {} \
                "${app[rename]}" \
                    --force \
                    --verbose \
                    "${dict[pattern]}" \
                    {}
    else
        "${app[rename]}" \
            --force \
            --verbose \
            "${dict[pattern]}" \
            "$@"
    fi
    return 0
}

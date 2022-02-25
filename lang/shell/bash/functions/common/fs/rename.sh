#!/usr/bin/env bash

koopa_rename_from_csv() { # {{{1
    # """
    # Rename files from CSV template.
    # @note Updated 2022-02-17.
    #
    # @usage koopa::rename_from_csv CSV_FILE
    # """
    local file line
    koopa::assert_has_args "$#"
    file="${1:?}"
    koopa::assert_is_file_type --ext='csv' "$file"
    while read -r line
    do
        local from to
        from="${line%,*}"
        to="${line#*,}"
        koopa::mv "$from" "$to"
    done < "$file"
    return 0
}

# FIXME Need to test that this works recursively using 'koopa::find'.
koopa::rename_lowercase() { # {{{1
    # """
    # Rename files to lowercase.
    # @note Updated 2022-02-24.
    #
    # @usage koopa::rename_lowercase FILE...
    # """
    local app dict pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [rename]="$(koopa::locate_rename)"
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
        koopa::assert_is_dir "${dict[prefix]}"
        # Rename files.
        koopa::find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict[prefix]}" \
            --print0 \
            --sort \
            --type='f' \
        | "${app[xargs]}" \
            --no-run-if-empty \
            --null \
            -I {} \
            "${app[rename]}" \
                --force \
                --verbose \
                "${dict[pattern]}" \
                {}
        # Rename directories.
        koopa::find \
            --exclude='.*' \
            --min-depth=1 \
            --pattern='*[A-Z]*' \
            --prefix="${dict[prefix]}" \
            --print0 \
            --type='d' \
        | "${app[xargs]}" \
            --no-run-if-empty \
            --null \
            -I {} \
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

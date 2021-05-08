#!/usr/bin/env bash

koopa_rename_from_csv() { # {{{1
    local file
    koopa::assert_has_args "$#"
    file="${1:?}"
    koopa::assert_is_file_type "$file" 'csv'
    while read -r line
    do
        from="${line%,*}"
        to="${line#*,}"
        koopa::mv "$from" "$to"
    done < "$file"
    return 0
}

koopa::rename_lowercase() { # {{{1
    local dir pos recursive
    koopa::assert_has_args "$#"
    koopa::assert_is_installed find rename
    recursive=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --recursive)
                recursive=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$recursive" -eq 1 ]]
    then
        dir="${1:-.}"
        # Rename files.
        find "$dir" \
            -mindepth 1 \
            -type f \
            -name '*[A-Z]*' \
            -not -name '.*' \
            -print0 \
            | sort --zero-terminated \
            | xargs -0 -I {} rename --force --verbose 'y/A-Z/a-z/' {}
        # Rename directories.
        find "$dir" \
            -mindepth 1 \
            -type d \
            -name '*[A-Z]*' \
            -not -name '.*' \
            -print0 \
            | sort --reverse --zero-terminated \
            | xargs -0 -I {} rename --force --verbose 'y/A-Z/a-z/' {}
    else
        rename --force --verbose 'y/A-Z/a-z/' "$@"
    fi
    return 0
}

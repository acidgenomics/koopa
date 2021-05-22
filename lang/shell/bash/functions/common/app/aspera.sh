#!/usr/bin/env bash

koopa::sra_prefetch_parallel() { # {{{1
    # """
    # Prefetch files from SRA in parallel.
    # @note Updated 2021-05-21.
    # """
    local file find jobs parallel sort
    koopa::activate_aspera
    koopa::assert_is_installed 'ascp' 'prefetch'
    find="$(koopa::locate_find)"
    jobs="$(koopa::cpu_count)"
    parallel="$(koopa::locate_parallel)"
    sort="$(koopa::locate_sort)"
    file="${1:-}"
    [ -z "$file" ] && file='SraAccList.txt'
    koopa::assert_is_file "$file"
    # Delete any temporary files that may have been created by previous run.
    "$find" . \(-name '*.lock' -o -name '*.tmp'\) -delete
    "$sort" -u "$file" \
        | "$parallel" -j "$jobs" \
            'prefetch --verbose {}'
    return 0
}

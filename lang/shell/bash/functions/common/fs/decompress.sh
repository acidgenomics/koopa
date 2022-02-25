#!/usr/bin/env bash

koopa_decompress() { # {{{1
    # """
    # Decompress a compressed file.
    # @note Updated 2022-01-11.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 2
    declare -A app
    declare -A dict=(
        [compress_ext_pattern]="$(koopa_compress_ext_pattern)"
        [source_file]="${1:?}"
        [manual_target_file]="${2:-}"
    )
    dict[auto_target_file]="$( \
        koopa_sub \
            --pattern="${dict[compress_ext_pattern]}" \
            --replacement='' \
            "${dict[source_file]}" \
    )"
    case "${dict[source_file]}" in
        *'.bz2')
            app[bunzip2]="$(koopa_locate_bunzip2)"
            "${app[bunzip2]}" \
                --force \
                --keep \
                --verbose \
                "${dict[source_file]}"
            ;;
        *'.gz')
            app[gunzip]="$(koopa_locate_gunzip)"
            "${app[gunzip]}" \
                --force \
                --keep \
                --verbose \
                "${dict[source_file]}"
            ;;
        *'.xz')
            app[xz]="$(koopa_locate_xz)"
            "${app[xz]}" \
                --decompress \
                --force \
                --keep \
                --verbose \
                "${dict[source_file]}"
            ;;
        *'.tar' | \
        *'.zip')
            koopa_stop "Use 'koopa_extract' instead."
            ;;
        *)
            koopa_stop "Unsupported extension: '${dict[source_file]}'."
            ;;
    esac
    koopa_assert_is_file "${dict[auto_target_file]}"
    if [[ -n "${dict[manual_target_file]}" ]]
    then
        koopa_mv \
            "${dict[auto_target_file]}" \
            "${dict[manual_target_file]}"
        dict[target_file]="${dict[manual_target_file]}"
    else
        dict[target_file]="${dict[auto_target_file]}"
    fi
    dict[target_file]="$(koopa_realpath "${dict[target_file]}")"
    koopa_print "${dict[target_file]}"
    return 0
}

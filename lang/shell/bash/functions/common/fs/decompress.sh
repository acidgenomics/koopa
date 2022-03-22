#!/usr/bin/env bash

koopa_decompress() { # {{{1
    # """
    # Decompress a compressed file.
    # @note Updated 2022-03-15.
    #
    # This function currently allows uncompressed files to pass through.
    # """
    local app dict
    koopa_assert_has_args_le "$#" 2
    declare -A app
    declare -A dict=(
        [alert]=1
        [compress_ext_pattern]="$(koopa_compress_ext_pattern)"
        [source_file]="${1:?}"
        [target_file]="${2:-}"
    )
    koopa_assert_is_file "${dict[source_file]}"
    if [[ -z "${dict[target_file]}" ]]
    then
        dict[target_file]="$( \
            koopa_sub \
                --pattern="${dict[compress_ext_pattern]}" \
                --replacement='' \
                "${dict[source_file]}" \
        )"
    fi
    if [[ "${dict[source_file]}" == "${dict[target_file]}" ]]
    then
        return 0
    fi
    case "${dict[source_file]}" in
        *'.bz2')
            app[bunzip2]="$(koopa_locate_bunzip2)"
            "${app[bunzip2]}" \
                --force \
                --keep \
                --stdout \
                "${dict[source_file]}" \
                > "${dict[target_file]}"
            ;;
        *'.gz')
            app[gunzip]="$(koopa_locate_gunzip)"
            "${app[gunzip]}" \
                --force \
                --keep \
                --stdout \
                "${dict[source_file]}" \
                > "${dict[target_file]}"
            ;;
        *'.xz')
            app[xz]="$(koopa_locate_xz)"
            "${app[xz]}" \
                --decompress \
                --force \
                --keep \
                --stdout \
                "${dict[source_file]}" \
                > "${dict[target_file]}"
            ;;
        *)
            koopa_cp "${dict[source_file]}" "${dict[target_file]}"
            ;;
    esac
    koopa_assert_is_file "${dict[target_file]}"
    return 0
}

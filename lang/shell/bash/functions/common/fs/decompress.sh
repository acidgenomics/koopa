#!/usr/bin/env bash

koopa_decompress() { # {{{1
    # """
    # Decompress a compressed file.
    # @note Updated 2022-03-24.
    #
    # This function currently allows uncompressed files to pass through.
    #
    # @examples
    # # How to make a program "gzip aware", by redirecting via process
    # # substitution. Particularly useful for some NGS tools like STAR.
    # > head -n 1 <(koopa_decompress --stdout 'sample.fastq.gz')
    # # @A01587:114:GW2203131905th:2:1101:5791:1031 1:N:0:CGATCAGT+TTAGAGAG
    # """
    local cmd cmd_args dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [compress_ext_pattern]="$(koopa_compress_ext_pattern)"
        [stdout]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--stdout')
                dict[stdout]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_le "$#" 2
    dict[source_file]="${1:?}"
    dict[target_file]="${2:-}"
    koopa_assert_is_file "${dict[source_file]}"
    case "${dict[stdout]}" in
        '0')
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
            ;;
        '1')
            [[ -z "${dict[target_file]}" ]] || return 1
            ;;
    esac
    case "${dict[source_file]}" in
        *'.bz2' | *'.gz' | *'.xz')
            case "${dict[source_file]}" in
                *'.bz2')
                    cmd="$(koopa_locate_bzip2)"
                    ;;
                *'.gz')
                    cmd="$(koopa_locate_gzip)"
                    ;;
                *'.xz')
                    cmd="$(koopa_locate_xz)"
                    ;;
            esac
            cmd_args=(
                '--decompress' # '-d'
                '--force' # '-f'
                '--keep' # '-k'
                '--stdout' # '-c'
                "${dict[source_file]}"
            )
            case "${dict[stdout]}" in
                '0')
                    "$cmd" "${cmd_args[@]}" > "${dict[target_file]}"
                    ;;
                '1')
                    "$cmd" "${cmd_args[@]}"
                    ;;
            esac
            ;;
        *)
            case "${dict[stdout]}" in
                '0')
                    koopa_cp "${dict[source_file]}" "${dict[target_file]}"
                    ;;
                '1')
                    cmd="$(koopa_locate_cat)"
                    "$cmd" "${dict[source_file]}"
                    ;;
            esac
            ;;
    esac
    if [[ "${dict[stdout]}" -eq 0 ]]
    then
        koopa_assert_is_file "${dict[target_file]}"
    fi
    return 0
}

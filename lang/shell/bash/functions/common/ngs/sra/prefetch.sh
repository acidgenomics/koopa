#!/usr/bin/env bash

koopa::sra_prefetch() { # {{{1
    # """
    # Prefetch files from SRA (in parallel).
    # @note Updated 2022-02-10.
    #
    # @examples
    # > koopa::sra_prefetch_parallel \
    # >     --accession-file='sra-acc-list.txt' \
    # >     --output-directory='sra'
    #
    # @seealso
    # - Conda build of sratools prefetch isn't currently working on macOS.
    #   https://github.com/ncbi/sra-tools/issues/497
    # """
    local app cmd dict
    declare -A app=(
        [prefetch]="$(koopa::locate_prefetch)"
    )
    declare -A dict=(
        [acc_file]='sra-accession-list.txt'
        [jobs]="$(koopa::cpu_count)"
        [output_dir]='sra'
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--accession-file='*)
                dict[acc_file]+=("${1#*=}")
                shift 1
                ;;
            '--accession-file')
                dict[acc_file]+=("${2:?}")
                shift 2
                ;;
            '--output-directory='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-directory')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Invalid ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa::assert_is_file "${dict[acc_file]}"
    dict[output_dir]="$(koopa::init_dir "${dict[output_dir]}")"
    cmd=(
        "${app[prefetch]}"
        '--force' 'no'
        '--output-directory' "${dict[output_dir]}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    "${app[parallel]}" \
        --arg-file "${dict[acc_file]}" \
        --bar \
        --eta \
        --jobs "${dict[jobs]}" \
        --progress \
        --will-cite \
        "${cmd[*]}"
    return 0
}

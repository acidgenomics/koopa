#!/usr/bin/env bash

koopa_sra_prefetch() {
    # """
    # Prefetch files from SRA (in parallel).
    # @note Updated 2023-11-06.
    #
    # @seealso
    # - Conda build of sratools prefetch isn't currently working on macOS.
    #   https://github.com/ncbi/sra-tools/issues/497
    #
    # @examples
    # > koopa_sra_prefetch \
    # >     --accession-file='srp049596-accession-list.txt' \
    # >     --output-directory='srp049596-prefetch'
    # """
    local -A app dict
    local -a prefetch_cmd
    app['parallel']="$(koopa_locate_parallel --allow-system)"
    app['prefetch']="$(koopa_locate_sra_prefetch)"
    koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
    dict['jobs']="$(koopa_cpu_count)"
    dict['output_dir']='sra'
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--accession-file='*)
                dict['acc_file']="${1#*=}"
                shift 1
                ;;
            '--accession-file')
                dict['acc_file']="${2:?}"
                shift 2
                ;;
            '--output-directory='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-directory')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--accession-file' "${dict['acc_file']}" \
        '--output-directory' "${dict['output_dir']}"
    koopa_assert_is_file "${dict['acc_file']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Prefetching SRA files to '${dict['output_dir']}'."
    prefetch_cmd=(
        "${app['prefetch']}"
        '--force' 'no'
        '--max-size' '500G'
        '--output-directory' "${dict['output_dir']}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        '{}'
    )
    "${app['parallel']}" \
        --arg-file "${dict['acc_file']}" \
        --bar \
        --eta \
        --jobs "${dict['jobs']}" \
        --progress \
        --will-cite \
        "${prefetch_cmd[*]}"
    return 0
}

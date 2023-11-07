#!/usr/bin/env bash

koopa_sra_prefetch() {
    # """
    # Prefetch files from SRA.
    # @note Updated 2023-11-07.
    #
    # Alternatively, can sync directly from AWS with:
    # > aws s3 sync s3://sra-pub-run-odp/sra/<SRR_ID>/ ./<SRR_ID>/
    #
    # @examples
    # > koopa_sra_prefetch \
    # >     --accession-file='srp049596-accession-list.txt' \
    # >     --output-directory='srp049596-prefetch'
    # """
    local -A app dict
    local -a prefetch_args
    app['prefetch']="$(koopa_locate_sra_prefetch)"
    koopa_assert_is_executable "${app[@]}"
    dict['acc_file']=''
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
    koopa_assert_is_ncbi_sra_toolkit_configured
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Prefetching SRA samples defined in '${dict['acc_file']}' \
to '${dict['output_dir']}'."
    prefetch_args+=(
        '--force' 'no'
        '--max-size' '500G'
        '--output-directory' "${dict['output_dir']}"
        '--progress'
        '--resume' 'yes'
        '--type' 'sra'
        '--verbose'
        '--verify' 'yes'
        "${dict['acc_file']}"
    )
    "${app['prefetch']}" "${prefetch_args[@]}"
    return 0
}

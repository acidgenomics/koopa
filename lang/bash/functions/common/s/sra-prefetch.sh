#!/usr/bin/env bash

koopa_sra_prefetch() {
    # """
    # Prefetch files from SRA.
    # @note Updated 2023-11-16.
    #
    # Alternatively, can sync directly from AWS with:
    # > aws s3 sync s3://sra-pub-run-odp/sra/<SRR_ID>/ ./<SRR_ID>/
    #
    # @seealso
    # - https://www.ncbi.nlm.nih.gov/sra/docs/sra-aws-download/
    # - https://bioinformatics.stackexchange.com/questions/12937/
    # - https://bioinformaticsworkbook.org/dataAcquisition/fileTransfer/sra.html
    # - http://barcwiki.wi.mit.edu/wiki/SOPs/qc_SRA
    # - https://stackoverflow.com/questions/14428609/
    # - https://www.gnu.org/software/parallel/man.html
    #
    # @examples
    # > koopa_sra_prefetch \
    # >     --accession-file='srp049596-accession-list.txt' \
    # >     --output-dir='srp049596-prefetch'
    # """
    local -A app dict
    local -a parallel_cmd
    app['prefetch']="$(koopa_locate_sra_prefetch)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'SRR_Acc_List.txt'.
    dict['acc_file']=''
    dict['jobs']="$(koopa_cpu_count)"
    # Set a hard limit of 4 concurrent transfers.
    [[ "${dict['jobs']}" -gt 4 ]] &&  dict['jobs']=4
    # e.g. 'sra'.
    dict['output_dir']=''
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
            '--output-dir='* | \
            '--output-directory='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir' | \
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
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_file "${dict['acc_file']}"
    koopa_assert_is_ncbi_sra_toolkit_configured
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Prefetching SRA samples defined in '${dict['acc_file']}' \
to '${dict['output_dir']}'."
    parallel_cmd=(
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
    koopa_parallel \
        --arg-file="${dict['acc_file']}" \
        --command="${parallel_cmd[*]}" \
        --jobs="${dict['jobs']}"
    return 0
}

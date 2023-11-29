#!/usr/bin/env bash

koopa_salmon_detect_fastq_library_type() {
    # """
    # Detect library type (strandedness) of input FASTQs.
    # @note Updated 2023-11-29.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html#skipquant
    # - https://www.biostars.org/p/9467617/
    # - https://github.com/COMBINE-lab/salmon/issues/489
    #
    # @examples
    # Paired-end:
    # > koopa_salmon_detect_fastq_library_type \
    # >     --fastq-r1-file='DMSO-1_R1_001.fastq.gz' \
    # >     --fastq-r2-file='DMSO-1_R2_001.fastq.gz' \
    # >     --index-dir='indexes/salmon-gencode'
    # # IU
    #
    # Single-end:
    # > koopa_salmon_detect_fastq_library_type \
    # >     --fastq-r1-file='DMSO-1_R1_001.fastq.gz' \
    # >     --index-dir='indexes/salmon-gencode'
    # # U
    # """
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['head']="$(koopa_locate_head --allow-system)"
    app['jq']="$(koopa_locate_jq --allow-system)"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    dict['fastq_r1_file']=''
    dict['fastq_r2_file']=''
    dict['index_dir']=''
    dict['n']='1000000'
    dict['threads']="$(koopa_cpu_count)"
    dict['tmp_dir']="$(koopa_tmp_dir_in_wd)"
    dict['output_dir']="${dict['tmp_dir']}/quant"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--index-dir' "${dict['index_dir']}"
    koopa_assert_is_file "${dict['fastq_r1_file']}"
    koopa_assert_is_dir "${dict['index_dir']}"
    quant_args+=(
        "--index=${dict['index_dir']}"
        '--libType=A'
        '--no-version-check'
        "--output=${dict['output_dir']}"
        '--quiet'
        '--skipQuant'
        "--threads=${dict['threads']}"
    )
    if [[ -n "${dict['fastq_r2_file']}" ]]
    then
        koopa_assert_is_file "${dict['fastq_r2_file']}"
        dict['mates1']="${dict['tmp_dir']}/mates1.fastq"
        dict['mates2']="${dict['tmp_dir']}/mates2.fastq"
        koopa_decompress --stdout "${dict['fastq_r1_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['mates1']}"
        koopa_decompress --stdout "${dict['fastq_r2_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['mates2']}"
        quant_args+=(
            "--mates1=${dict['mates1']}"
            "--mates2=${dict['mates2']}"
        )
    else
        dict['unmated_reads']="${dict['tmp_dir']}/reads.fastq"
        koopa_decompress --stdout "${dict['fastq_r1_file']}" \
            | "${app['head']}" -n "${dict['n']}" \
            > "${dict['unmated_reads']}"
        quant_args+=("--unmatedReads=${dict['unmated_reads']}")
    fi
    "${app['salmon']}" quant "${quant_args[@]}" 1>&2
    dict['json_file']="${dict['output_dir']}/lib_format_counts.json"
    koopa_assert_is_file "${dict['json_file']}"
    dict['lib_type']="$( \
        "${app['jq']}" --raw-output '.expected_format' "${dict['json_file']}" \
    )"
    koopa_print "${dict['lib_type']}"
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

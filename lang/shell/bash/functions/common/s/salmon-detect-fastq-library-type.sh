#!/usr/bin/env bash

koopa_salmon_detect_fastq_library_type() {
    # """
    # Detect library type of input FASTQs.
    # @note Updated 2022-07-27.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html#skipquant
    # - https://www.biostars.org/p/9467617/
    # - https://github.com/COMBINE-lab/salmon/issues/489
    #
    # @examples
    # Paired-end:
    # > koopa_salmon_detect_fastq_library_type \
    # >     'DMSO-1_R1_001.fastq.gz' \
    # >     'DMSO-1_R2_001.fastq.gz'
    # # FIXME Show example code.
    #
    # Single-end:
    # > koopa_salmon_detect_fastq_library_type \
    # >     'DMSO-1_R1_001.fastq.gz'
    # # FIXME Show example code.
    # """
    local app dict quant_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [head]="$(koopa_locate_head)"
        [jq]="$(koopa_locate_jq)"
        [salmon]="$(koopa_locate_salmon)"
    )
    [[ -x "${app[head]}" ]] || return 1
    [[ -x "${app[jq]}" ]] || return 1
    [[ -x "${app[salmon]}" ]] || return 1
    declare -A dict=(
        [lib_type]='A'
        [n]='400000'
        [threads]="$(koopa_cpu_count)"
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    dict[output_dir]="${dict[tmp_dir]}/quant"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict[fastq_r1_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict[fastq_r1_file]="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict[fastq_r2_file]="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict[fastq_r2_file]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-r1-file' "${dict[fastq_r1_file]}" \
        '--index-dir' "${dict[index_dir]}"
    koopa_assert_is_file "${dict[fastq_r1_file]}"
    koopa_assert_is_dir "${dict[index_dir]}"
    quant_args=(
        "--index=${dict[index_dir]}"
        "--libType=${dict[lib_type]}"
        '--no-version-check'
        "--output=${dict[output_dir]}"
        '--quiet'
        '--skipQuant'
        "--threads=${dict[threads]}"
    )
    case "$#" in
        '1')
            dict[unmated_reads]="${dict[tmp_dir]}/reads.fastq"
            koopa_decompress --stdout "${dict[fastq_r1_file]}" \
                | "${app[head]}" -n "${dict[n]}" \
                > "${dict[unmated_reads]}"
            quant_args+=(
                "--unmatedReads=${dict[unmated_reads]}"
            )
            ;;
        '2')
            koopa_assert_is_file "${dict[fastq_r2_file]}"
            dict[mates1]="${dict[tmp_dir]}/mates1.fastq"
            dict[mates2]="${dict[tmp_dir]}/mates2.fastq"
            koopa_decompress --stdout "${dict[fastq_r1_file]}" \
                | "${app[head]}" -n "${dict[n]}" \
                > "${dict[mates1]}"
            koopa_decompress --stdout "${dict[fastq_r2_file]}" \
                | "${app[head]}" -n "${dict[n]}" \
                > "${dict[mates2]}"
            quant_args+=(
                "--mates1=${dict[mates1]}"
                "--mates2=${dict[mates2]}"
            )
            ;;
    esac
    "${app[salmon]}" quant "${quant_args[@]}"
    # FIXME Extract library strandedness in 'lib_format_counts.json' 'expected_format' value.
    # > koopa_print "${dict[lib_type]}"
    # > koopa_rm "${dict[tmp_dir]}"
    return 0
}

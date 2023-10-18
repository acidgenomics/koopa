#!/usr/bin/env bash

# FIXME Strandedness is not common for single end sequencing.
# FIXME Need to add lib-type here, defaulting to 'A'
# FIXME Need to add support for unstranded.
# FIXME Set '--rna-strandedness from this.

koopa_hisat2_align_single_end_per_sample() {
    # """
    # Run HISAT2 aligner on a single-end sample.
    # @note Updated 2023-10-18.
    #
    # @examples
    # > koopa_hisat2_align_single_end_per_sample \
    # >     --fastq-file='fastq/sample1_001.fastq.gz' \
    # >     --fastq-tail='_001.fastq.gz' \
    # >     --index-dir='hisat2-index' \
    # >     --output-dir='hisat2'
    # """
    local -A app dict
    local -a align_args
    koopa_assert_has_args "$#"
    app['hisat2']="$(koopa_locate_hisat2)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'sample1_001.fastq.gz'.
    dict['fastq_file']=''
    # e.g. '_001.fastq.gz'.
    dict['fastq_tail']=''
    # e.g. 'hisat2-index'.
    dict['index_dir']=''
    # Using salmon fragment library type conventions here.
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    # e.g. 'hisat2'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-file='*)
                dict['fastq_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-file')
                dict['fastq_file']="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict['fastq_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict['fastq_tail']="${2:?}"
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
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fastq-file' "${dict['fastq_file']}" \
        '--fastq-tail' "${dict['fastq_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "HISAT2 align requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_file']}"
    dict['fastq_file']="$(koopa_realpath "${dict['fastq_file']}")"
    dict['fastq_bn']="$(koopa_basename "${dict['fastq_file']}")"
    dict['fastq_bn']="${dict['fastq_bn']/${dict['tail']}/}"
    dict['id']="${dict['fastq_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    dict['hisat2_idx']="${dict['index_dir']}/index"
    dict['sam_file']="${dict['output_dir']}/${dict['id']}.sam"
    align_args+=(
        '-S' "${dict['sam_file']}"
        '-U' "${dict['fastq_file']}"
        '-q'
        '-x' "${dict['hisat2_idx']}"
        '--new-summary'
        '--threads' "${dict['threads']}"
    )
    dict['lib_type']="$(koopa_hisat2_fastq_library_type "${dict['lib_type']}")"
    if [[ -n "${dict['lib_type']}" ]]
    then
        align_args+=('--rna-strandedness' "${dict['lib_type']}")
    fi
    dict['quality_flag']="$( \
        koopa_hisat2_fastq_quality_format "${dict['fastq_r1_file']}" \
    )"
    if [[ -n "${dict['quality_flag']}" ]]
    then
        align_args+=("${dict['quality_flag']}")
    fi
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['hisat2']}" "${align_args[@]}"
    # FIXME Convert the SAM file to BAM file here?
    return 0
}

#!/usr/bin/env bash

koopa_bowtie2_align_per_sample() {
    # """
    # Run bowtie2 alignment on multiple paired-end FASTQ files.
    # @note Updated 2022-10-11.
    # """
    local app dict
    local -A app dict
    koopa_assert_has_args "$#"
    app['bowtie2']="$(koopa_locate_bowtie2)"
    app['tee']="$(koopa_locate_tee)"
    [[ -x "${app['bowtie2']}" ]] || exit 1
    [[ -x "${app['tee']}" ]] || exit 1
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. '_R1_001.fastq.gz'.
    dict['fastq_r1_tail']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. '_R2_001.fastq.gz'.
    dict['fastq_r2_tail']=''
    # e.g. 'bowtie2-index'.
    dict['index_dir']=''
    # e.g. 'bowtie2'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
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
            '--fastq-r1-tail='*)
                dict['fastq_r1_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-tail')
                dict['fastq_r1_tail']="${2:?}"
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
            '--fastq-r2-tail='*)
                dict['fastq_r2_tail']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-tail')
                dict['fastq_r2_tail']="${2:?}"
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
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r1-tail' "${dict['fastq_r1_tail']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--fastq-r2-tail' "${dict['fastq_r2_tail']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    # NOTE Consider setting memory requirement here.
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r1_bn']="${dict['fastq_r1_bn']/${dict['fastq_r1_tail']}/}"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['fastq_r2_bn']="${dict['fastq_r2_bn']/${dict['fastq_r2_tail']}/}"
    koopa_assert_are_identical "${dict['fastq_r1_bn']}" "${dict['fastq_r2_bn']}"
    dict['id']="${dict['fastq_r1_bn']}"
    dict['output_dir']="${dict['output_dir']}/${dict['id']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['id']}'."
        return 0
    fi
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Aligning '${dict['id']}' in '${dict['output_dir']}'."
    dict['index_base']="${dict['index_dir']}/bowtie2"
    dict['sam_file']="${dict['output_dir']}/${dict['id']}.sam"
    dict['log_file']="${dict['output_dir']}/align.log"
    align_args=(
        '--local'
        '--sensitive-local'
        '--rg-id' "${dict['id']}"
        '--rg' 'PL:illumina'
        '--rg' "PU:${dict['id']}"
        '--rg' "SM:${dict['id']}"
        '--threads' "${dict['threads']}"
        '-1' "${dict['fastq_r1_file']}"
        '-2' "${dict['fastq_r2_file']}"
        '-S' "${dict['sam_file']}"
        '-X' 2000
        '-q'
        '-x' "${dict['index_base']}"
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['bowtie2']}" "${align_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

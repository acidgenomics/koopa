#!/usr/bin/env bash

koopa_bowtie2_index() {
    # """
    # Generate bowtie2 index.
    # @note Updated 2022-10-11.
    # """
    local app dict index_args
    declare -A app dict
    koopa_assert_has_args "$#"
    app['bowtie2_build']="$(koopa_locate_bowtie2_build)"
    app['tee']="$(koopa_locate_tee)"
    [[ -x "${app['bowtie2_build']}" ]] || exit 1
    [[ -x "${app['tee']}" ]] || exit 1
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'bowtie2-index'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
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
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_file "${dict['genome_fasta_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Generating bowtie2 index at '${dict['output_dir']}'."
    # This step adds 'bowtie2.*' prefix to the files created in the output.
    dict['index_base']="${dict['output_dir']}/bowtie2"
    dict['log_file']="${dict['output_dir']}/index.log"
    index_args=(
        "--threads=${dict['threads']}"
        '--verbose'
        "${dict['genome_fasta_file']}"
        "${dict['index_base']}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app['bowtie2_build']}" "${index_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

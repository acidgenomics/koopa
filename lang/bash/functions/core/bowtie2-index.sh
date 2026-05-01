#!/usr/bin/env bash

# TODO Add support for pushing to S3 as a tarball.

_koopa_bowtie2_index() {
    # """
    # Generate bowtie2 index.
    # @note Updated 2023-10-20.
    # """
    local -A app dict
    local -a index_args
    _koopa_assert_has_args "$#"
    app['bowtie2_build']="$(_koopa_locate_bowtie2_build)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'indexes/bowtie2-gencode'.
    dict['output_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-dir' "${dict['output_dir']}"
    _koopa_assert_is_file "${dict['genome_fasta_file']}"
    _koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(_koopa_init_dir "${dict['output_dir']}")"
    _koopa_alert "Generating bowtie2 index at '${dict['output_dir']}'."
    # This step adds 'bowtie2.*' prefix to the files created in the output.
    dict['index_base']="${dict['output_dir']}/bowtie2"
    dict['log_file']="${dict['output_dir']}/index.log"
    index_args=(
        "--threads=${dict['threads']}"
        '--verbose'
        "${dict['genome_fasta_file']}"
        "${dict['index_base']}"
    )
    _koopa_dl 'Index args' "${index_args[*]}"
    "${app['bowtie2_build']}" "${index_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

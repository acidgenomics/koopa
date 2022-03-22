#!/usr/bin/env bash

koopa_star_index() { # {{{1
    # """
    # Create a genome index for STAR aligner.
    # @note Updated 2022-03-22.
    #
    # Doesn't currently support compressed files as input.
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     ngsalign/star.py
    # - https://github.com/nf-core/rnaseq/blob/master/modules/local/
    #     star_genomegenerate.nf
    # """
    local app dict index_args
    declare -A app=(
        [star]="$(koopa_locate_star)"
    )
    declare -A dict=(
        [genome_fastq_file]=''
        [gtf_file]=''
        [output_dir]=''
        [threads]="$(koopa_cpu_count)"
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--genome-fasta-file='*)
                dict[genome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict[genome_fasta_file]="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[gtf_file]}"
    koopa_alert "Generating STAR index at '${dict[output_dir]}'."
    dict[tmp_genome_fasta_file]="$(\
        koopa_decompress "${dict[genome_fasta_file]}" \
    )"
    dict[tmp_gtf_file]="$(\
        koopa_decompress "${dict[gtf_file]}" \
    )"
    index_args+=(
        '--runMode' 'genomeGenerate'
        '--genomeDir' "${dict[output_dir]}/"
        '--genomeFastaFiles' "${dict[tmp_genome_fasta_file]}"
        '--runThreadN' "${dict[threads]}"
        '--sjdbGTFfile' "${dict[tmp_gtf_file]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[star]}" "${index_args[@]}"
    koopa_alert_success "STAR index created at '${dict[output_dir]}'."
    return 0
}

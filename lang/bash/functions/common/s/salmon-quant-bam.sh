#!/usr/bin/env bash

# FIXME Add support for AWS sync here.
# FIXME Need to set the output directory per sample here automatically.

koopa_salmon_quant_bam() {
    # """
    # Run salmon quant on multiple transcriptome-aligned BAMs in a directory.
    # @note Updated 2023-06-16.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    #   #quantifying-in-alignment-based-mode
    #
    # @examples
    # > koopa_salmon_quant_bam \
    # >     --bam-dir='bam' \
    # >     --output-dir='salmon' \
    # >     --transcriptome-fasta-file='transcriptome.fa.gz'
    # """
    local -A dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args "$#"
    # e.g. 'bam'.
    dict['bam_dir']=''
    # Detect library fragment type (strandedness) automatically.
    dict['lib_type']='A'
    # e.g. 'salmon'.
    dict['output_dir']=''
    # e.g. 'gencode.v39.transcripts.fa.gz'.
    dict['transcriptome_fasta_file']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-dir='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-dir')
                dict['bam_dir']="${2:?}"
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
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-dir' "${dict['bam_dir']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    koopa_assert_is_dir "${dict['bam_dir']}"
    koopa_assert_is_file "${dict['transcriptome_fasta_file']}"
    dict['bam_dir']="$(koopa_realpath "${dict['bam_dir']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    koopa_h1 'Running salmon quant.'
    koopa_dl \
        'Transcriptome FASTA' "${dict['transcriptome_fasta_file']}" \
        'BAM dir' "${dict['bam_dir']}" \
        'Output dir' "${dict['output_dir']}"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.bam" \
            --prefix="${dict['bam_dir']}" \
            --sort \
    )"
    if koopa_is_array_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['bam_dir']}'."
    fi
    koopa_assert_is_file "${bam_files[@]}"
    koopa_alert_info "$(koopa_ngettext \
        --num="${#bam_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for bam_file in "${bam_files[@]}"
    do
        koopa_salmon_quant_bam_per_sample \
            --bam-file="$bam_file" \
            --lib-type="${dict['lib_type']}" \
            --output-dir="${dict['output_dir']}" \
            --transcriptome-fasta-file="${dict['transcriptome_fasta_file']}"
    done
    koopa_alert_success 'salmon quant was successful.'
    return 0
}

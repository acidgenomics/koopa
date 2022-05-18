#!/usr/bin/env bash

koopa_fasta_generate_decoy_transcriptome_file() {
    # """
    # Generate decoy transcriptome "gentrome" (e.g. for salmon index).
    # @note Updated 2022-03-25.
    #
    # This function generates aFASTA file named 'gentrome.fa.gz', containing
    # input from both the genome and transcriptome FASTA files.
    #
    # The genome targets (decoys) should come after the transcriptome targets
    # in the 'gentrome' reference file.
    #
    # @seealso
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    #     #preparing-transcriptome-indices-mapping-based-mode
    # - https://salmon.readthedocs.io/en/latest/
    #     salmon.html#quantifying-in-mapping-based-mode
    # - https://combine-lab.github.io/alevin-tutorial/2019/selective-alignment/
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/
    #     modules/salmon/index/main.nf
    # - https://github.com/COMBINE-lab/SalmonTools/blob/master/
    #     scripts/generateDecoyTranscriptome.sh
    # - https://github.com/marbl/MashMap/
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     rnaseq/salmon.py#L244
    # - https://github.com/chapmanb/cloudbiolinux/blob/master/ggd-recipes/
    #     hg38/salmon-decoys.yaml
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
    )
    declare -A dict=(
        [genome_fasta_file]=''
        [output_file]='' # 'gentrome.fa.gz'
        [transcriptome_fasta_file]=''
    )
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
            '--output-file='*)
                dict[output_file]="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict[output_file]="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict[transcriptome_fasta_file]="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict[transcriptome_fasta_file]="${2:?}"
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
        '--output-file' "${dict[output_file]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_file "${dict[output_file]}"
    koopa_assert_is_file \
        "${dict[genome_fasta_file]}" \
        "${dict[transcriptome_fasta_file]}"
    dict[genome_fasta_file]="$(koopa_realpath "${dict[genome_fasta_file]}")"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict[genome_fasta_file]}"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_matching_regex \
        --pattern='\.gz$' \
        --string="${dict[output_file]}"
    koopa_alert "Generating decoy-aware transcriptome \
at '${dict[output_file]}'."
    koopa_dl \
        'Genome FASTA file' "${dict[genome_fasta_file]}" \
        'Transcriptome FASTA file' "${dict[transcriptome_fasta_file]}"
    "${app[cat]}" \
        "${dict[transcriptome_fasta_file]}" \
        "${dict[genome_fasta_file]}" \
        > "${dict[output_file]}"
    koopa_assert_is_file "${dict[output_file]}"
    return 0
}

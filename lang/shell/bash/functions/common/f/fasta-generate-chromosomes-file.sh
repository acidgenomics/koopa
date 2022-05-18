#!/usr/bin/env bash

koopa_fasta_generate_chromosomes_file() {
    # """
    # Generate chromosomes text file from genome FASTA.
    # @note Updated 2022-03-24.
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [grep]="$(koopa_locate_grep)"
        [sed]="$(koopa_locate_sed)"
    )
    declare -A dict=(
        # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
        [genome_fasta_file]=''
        # e.g. 'chromosomes.txt'
        [output_file]=''
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--genome-fasta-file' "${dict[genome_fasta_file]}" \
        '--output-file' "${dict[output_file]}"
    koopa_assert_is_not_file "${dict[output_file]}"
    koopa_assert_is_file "${dict[genome_fasta_file]}"
    koopa_alert "Generating '${dict[output_file]}' from \
'${dict[genome_fasta_file]}'."
    "${app[grep]}" '^>' \
        <(koopa_decompress --stdout "${dict[genome_fasta_file]}") \
        | "${app[cut]}" -d ' ' -f '1' \
        > "${dict[output_file]}"
    "${app[sed]}" \
        -i.bak \
        's/>//g' \
        "${dict[output_file]}"
    koopa_assert_is_file "${dict[output_file]}"
    return 0
}

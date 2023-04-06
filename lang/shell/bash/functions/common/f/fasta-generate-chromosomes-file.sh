#!/usr/bin/env bash

koopa_fasta_generate_chromosomes_file() {
    # """
    # Generate chromosomes text file from genome FASTA.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['cut']="$(koopa_locate_cut --allow-system)"
    app['grep']="$(koopa_locate_grep)"
    app['sed']="$(koopa_locate_sed)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'
    dict['genome_fasta_file']=''
    # e.g. 'chromosomes.txt'
    dict['output_file']=''
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
            '--output-file='*)
                dict['output_file']="${1#*=}"
                shift 1
                ;;
            '--output-file')
                dict['output_file']="${2:?}"
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
        '--output-file' "${dict['output_file']}"
    koopa_assert_is_not_file "${dict['output_file']}"
    koopa_assert_is_file "${dict['genome_fasta_file']}"
    koopa_alert "Generating '${dict['output_file']}' from \
'${dict['genome_fasta_file']}'."
    # NOTE This command appears to be causing shellcheck to fail inside of our
    # cached 'common.sh' file. Can we rework this approach?
    "${app['grep']}" '^>' \
        <(koopa_decompress --stdout "${dict['genome_fasta_file']}") \
        | "${app['cut']}" -d ' ' -f '1' \
        > "${dict['output_file']}"
    "${app['sed']}" \
        -i.bak \
        's/>//g' \
        "${dict['output_file']}"
    koopa_assert_is_file "${dict['output_file']}"
    return 0
}

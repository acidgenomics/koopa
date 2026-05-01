#!/usr/bin/env bash

_koopa_fasta_generate_chromosomes_file() {
    # """
    # Generate chromosomes text file from genome FASTA.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    _koopa_assert_has_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['grep']="$(_koopa_locate_grep)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--output-file' "${dict['output_file']}"
    _koopa_assert_is_not_file "${dict['output_file']}"
    _koopa_assert_is_file "${dict['genome_fasta_file']}"
    _koopa_alert "Generating '${dict['output_file']}' from \
'${dict['genome_fasta_file']}'."
    # NOTE This command appears to be causing shellcheck to fail inside of our
    # cached 'common.sh' file. Can we rework this approach?
    "${app['grep']}" '^>' \
        <(_koopa_decompress --stdout "${dict['genome_fasta_file']}") \
        | "${app['cut']}" -d ' ' -f '1' \
        > "${dict['output_file']}"
    "${app['sed']}" \
        -i.bak \
        's/>//g' \
        "${dict['output_file']}"
    _koopa_assert_is_file "${dict['output_file']}"
    return 0
}

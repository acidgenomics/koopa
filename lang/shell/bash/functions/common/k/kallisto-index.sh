#!/usr/bin/env bash

koopa_kallisto_index() {
    # """
    # Generate kallisto index.
    # @note Updated 2022-03-25.
    #
    # @seealso
    # - kallisto index --help
    #
    # @examples
    # > koopa_kallisto_index \
    # >     --output-dir='salmon-index' \
    # >     --transcriptome-fasta-file='gencode.v39.transcripts.fa.gz'
    # """
    local app dict index_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [kallisto]="$(koopa_locate_kallisto)"
    )
    declare -A dict=(
        [kmer_size]=31
        [mem_gb]="$(koopa_mem_gb)"
        [mem_gb_cutoff]=14
        # e.g. 'kallisto-index'.
        [output_dir]=''
        # e.g. 'gencode.v39.transcripts.fa.gz'.
        [transcriptome_fasta_file]=''
    )
    index_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
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
        '--output-dir' "${dict[output_dir]}" \
        '--transcriptome-fasta-file' "${dict[transcriptome_fasta_file]}"
    if [[ "${dict[mem_gb]}" -lt "${dict[mem_gb_cutoff]}" ]]
    then
        koopa_stop "kallisto index requires ${dict[mem_gb_cutoff]} GB of RAM."
    fi
    koopa_assert_is_file "${dict[transcriptome_fasta_file]}"
    dict[transcriptome_fasta_file]="$( \
        koopa_realpath "${dict[transcriptome_fasta_file]}" \
    )"
    koopa_assert_is_matching_regex \
        --pattern='\.fa(sta)?' \
        --string="${dict[transcriptome_fasta_file]}"
    koopa_assert_is_not_dir "${dict[output_dir]}"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    dict[index_file]="${dict[output_dir]}/kallisto.idx"
    koopa_alert "Generating kallisto index at '${dict[output_dir]}'."
    index_args+=(
        "--index=${dict[index_file]}"
        "--kmer-size=${dict[kmer_size]}"
        '--make-unique'
        "${dict[transcriptome_fasta_file]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    "${app[kallisto]}" index "${index_args[@]}"
    koopa_alert_success "kallisto index created at '${dict[output_dir]}'."
    return 0
}
